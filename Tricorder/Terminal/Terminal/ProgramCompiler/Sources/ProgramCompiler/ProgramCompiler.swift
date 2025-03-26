import Foundation
import Machine

extension OPCode: @retroactive CustomStringConvertible {
	public var description: String {
		switch self {
		case RXI: "RXI"
		case RXU: "RXU"
		case RXST: "RXST"
		case STRX: "STRX"
		case ADD: "ADD"
		case INC: "INC"
		case MUL: "MUL"
		case FN: "FN"
		case FNRX: "FNRX"
		case RET: "RET"
		default: rawValue.hexString
		}
	}
}

func err(_ msg: String) -> CompilationError { .init(description: msg) }

public extension Scope {

	init(program: String) throws {
		self = .empty
		var p = try Parser(tokens: tokenize(program: program))
		exprs = try p.statements()

		try exprs.forEach {
			if case let .typDecl(id, t) = $0 { try typeDecl(id, t) }
		}
		try exprs.forEach {
			if case let .varDecl(id, t, e) = $0 { try varDecl(id, t, e) }
		}
	}

	func compile() throws -> Program {
		var instructions = funcs.map(\.program.rawData).reduce(into: [], +=)

		if !instructions.isEmpty {
			guard instructions.count + 2 < UInt16.max else { throw err("Instructions are too large") }
			instructions.insert(FN(x: 0, yz: UInt16(instructions.count + 1)), at: 0)
		}

		for expr in exprs {
			switch expr {
			case let .varDecl(name, _, rhs):
				let v = try local(name).unwraped("Unknown id")
				instructions += try eval(expr: rhs, type: v.type, offset: UInt8(v.offset))
			case let .assignment(.id(id), rhs):
				guard let v = local(id) else { throw err("Unknown id") }
				instructions += try eval(expr: rhs, type: v.type, offset: UInt8(v.offset))
			case let .mul(.id(lID), .id(rID)):
				guard let l = local(lID) else { throw err("Unknown id") }
				guard let r = local(rID) else { throw err("Unknown id") }

				instructions += [
					MUL(x: 0, y: UInt8(l.offset), z: UInt8(r.offset))
				]
			case let .call(fn, _):
				if case let .id(id) = fn,
				   let fn = local(id),
				   case let .function(i, o) = fn.type {

					instructions += [
						FNRX(x: UInt8(fn.offset), yz: 0)
					]
				} else {
					throw err("Unknown function expr \(fn)")
				}
				break
			default:
				break
			}
		}

		instructions += [RET(x: 0, yz: 0)]
		return Program(rawData: instructions)
	}

	func sum(_ ret: UInt8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		switch (lhs, rhs) {
		case let (.id(id), .consti(c)):
			guard let v = local(id) else { throw err("Unknown id") }
			return [
				RXI(x: ret + 1, yz: UInt16(c)),
				ADD(x: ret, y: UInt8(v.offset), z: ret + 1)
			]
		default: throw err("Invalid sum")
		}
	}

	func mul(_ ret: UInt8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		switch (lhs, rhs) {
		case let (.id(lID), .id(rID)):
			guard let l = local(lID) else { throw err("Unknown id") }
			guard let r = local(rID) else { throw err("Unknown id") }
			return [
				MUL(x: ret, y: UInt8(l.offset), z: UInt8(r.offset))
			]
		default: throw err("Invalid mul")
		}
	}

	func call(_ ret: UInt8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		guard case let .id(v) = lhs, let fn = local(v) else {
			throw err("Unknown id")
		}
		guard case .function(type, let i) = fn.type else {
			throw err("Type mismatch")
		}

		return try eval(expr: rhs, type: i, offset: ret + UInt8(type.size)) + [
			FNRX(x: ret, y: UInt8(fn.offset), z: 0)
		]
	}

	private func eval(expr: Expr, type: Typ, offset: UInt8) throws -> [Instruction] {
		var instructions = [] as [Instruction]

		switch expr {
		case let .consti(int):
			instructions += [
				RXI(x: offset, yz: UInt16(int & 0xFFFF))
			] + (int > 0xFFFF ? [
				RXU(x: offset, yz: UInt16(int >> 16))
			] : [])
		case let .id(id):
			guard let v = local(id) else { throw err("Unknown id") }

			instructions += [
				RXI(x: UInt8(v.offset + v.type.size), yz: UInt16(0)),
				ADD(x: offset, y: UInt8(v.offset + v.type.size), z: UInt8(v.offset))
			]
		case let .call(lhs, rhs):
			instructions += try call(offset, type, lhs, rhs)
		case let .sum(lhs, rhs):
			instructions += try sum(offset, type, lhs, rhs)
		case let .mul(lhs, rhs):
			instructions += try mul(offset, type, lhs, rhs)
		case let .funktion(labels, exprs):
			instructions += [RXI(x: offset, yz: 1)]
		default:
			throw err("Invalid expression \(expr)")
		}
		return instructions
	}
}

extension UInt8 { var hexString: String { String(format: "%02x", self) } }

extension OPCode {

	func callAsFunction(x: UInt8, yz: UInt16) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(yz: i16(u: yz)))
	}
	func callAsFunction(x: UInt8, y: UInt8, z: UInt8) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(.init(y: i8(u: y), z: i8(u: z))))
	}
}
