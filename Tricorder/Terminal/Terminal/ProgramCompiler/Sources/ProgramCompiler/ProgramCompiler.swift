import Foundation
import Machine

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
		let compiledFuncs = funcs.map(\.program.rawData).reduce(into: [], +=)
		var instructions = compiledFuncs

		for expr in exprs {
			switch expr {
			case let .varDecl(name, _, rhs):
				let v = try local(name).unwraped("Unknown id \(name)")
				instructions += try eval(expr: rhs, type: v.type, offset: u8(v.offset))
			case let .assignment(.id(id), rhs):
				let v = try local(id).unwraped("Unknown id \(id)")
				instructions += try eval(expr: rhs, type: v.type, offset: u8(v.offset))
			case let .mul(.id(lID), .id(rID)):
				let l = try local(lID).unwraped("Unknown id \(lID)")
				let r = try local(rID).unwraped("Unknown id \(rID)")
				instructions += [MUL(x: 0, y: u8(l.offset), z: u8(r.offset))]
			case let .call(fn, a):
				if case let .id(id) = fn, let fn = local(id), case let .function(i, o) = fn.type {
					instructions += try eval(expr: a, type: i, offset: u8(o.size))
					instructions += [FNRX(x: u8(fn.offset), yz: 0)]
				} else {
					throw err("Unknown function expr \(fn)")
				}
				break
			default:
				break
			}
		}

		instructions += [RET(x: 0, yz: 0)]

		if parent() == nil {
			guard instructions.count < u16.max else { throw err("Instructions count > UInt16.max") }
			instructions.append(FN(x: 0, yz: u16(compiledFuncs.count)))
		}

		return Program(rawData: instructions)
	}

	func sum(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		switch (lhs, rhs) {
		case let (.consti(l), .consti(r)):
			return [RXI(x: ret, yz: u16(l + r))]
		case let (.id(id), .consti(c)), let (.consti(c), .id(id)):
			let v = try local(id).unwraped("Unknown id \(id)")
			guard v.type.resolved == .int else { throw err("Type mismatch \(v.type) != .int") }

			return [
				RXI(x: u8(size), yz: u16(c)),
				ADD(x: ret, y: u8(v.offset), z: u8(size))
			]
		case let (.id(lhs), .id(rhs)):
			let l = try local(lhs).unwraped("Unknown id \(lhs)")
			let r = try local(rhs).unwraped("Unknown id \(rhs)")
			guard l.type.resolved == r.type.resolved else { throw err("Type mismatch \(l.type) != \(r.type)") }

			return [
				ADD(x: ret, y: u8(l.offset), z: u8(r.offset))
			]
		default: throw err("Invalid sum")
		}
	}

	func mul(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		switch (lhs, rhs) {
		case let (.consti(l), .consti(r)):
			return [RXI(x: ret, yz: u16(l * r))]
		case let (.id(id), .consti(c)), let (.consti(c), .id(id)):
			let v = try local(id).unwraped("Unknown id \(id)")
			guard v.type.resolved == .int else { throw err("Type mismatch \(v.type) != .int") }

			return [
				RXI(x: u8(size), yz: u16(c)),
				MUL(x: ret, y: u8(v.offset), z: u8(size))
			]
		case let (.id(lID), .id(rID)):
			guard let l = local(lID) else { throw err("Unknown id") }
			guard let r = local(rID) else { throw err("Unknown id") }
			return [
				MUL(x: ret, y: u8(l.offset), z: u8(r.offset))
			]
		default: throw err("Invalid mul")
		}
	}

	func call(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		guard case let .id(v) = lhs, let fn = local(v) else {
			throw err("Unknown id")
		}
		guard case .function(type, let i) = fn.type else {
			throw err("Type mismatch")
		}

		return try eval(expr: rhs, type: i, offset: ret + u8(type.size)) + [
			FNRX(x: ret, y: u8(fn.offset), z: 0)
		]
	}

	private func eval(expr: Expr, type: Typ, offset: u8) throws -> [Instruction] {
		var instructions = [] as [Instruction]

		switch expr {
		case let .consti(int):
			instructions += [
				RXI(x: offset, yz: u16(int & 0xFFFF))
			] + (int > 0xFFFF ? [
				RXU(x: offset, yz: u16(int >> 16))
			] : [])
		case let .consts(s):
			let encoded = s.filter(\.isASCII).cString(using: .ascii) ?? []
			let itemAt: (Int) -> u8 = {
				$0 < encoded.count ? encoded[$0].magnitude : 0
			}
			guard case let .array(.char, cnt) = type, encoded.count < cnt else {
				throw err("Can't fit \"\(s)\" into \(type)")
			}
			instructions += (0..<((encoded.count + 3) / 4)).flatMap { idx in
				let i: u16 = u16(itemAt(idx * 4 + 0)) | u16(itemAt(idx * 4 + 1)) << 8
				let u: u16 = u16(itemAt(idx * 4 + 2)) | u16(itemAt(idx * 4 + 3)) << 8
				return [RXI(x: offset + u8(idx), yz: i), RXU(x: offset + u8(idx), yz: u)]
			}
		case let .id(id):
			let v = try local(id).unwraped("Unknown id \(id)")

			instructions += [
				RXI(x: u8(v.offset + v.type.size), yz: u16(0)),
				ADD(x: offset, y: u8(v.offset + v.type.size), z: u8(v.offset))
			]
		case let .call(lhs, rhs):
			instructions += try call(offset, type, lhs, rhs)
		case let .sum(lhs, rhs):
			instructions += try sum(offset, type, lhs, rhs)
		case let .mul(lhs, rhs):
			instructions += try mul(offset, type, lhs, rhs)
		case let .funktion(fid, _, _):
			let fn = try funcs.first { $0.id == fid }.unwraped("Unknown func \(fid)")
			instructions += [RXI(x: offset, yz: u16(fn.offset))]
		case let .tuple(fs):
			if case let .tuple(fields) = type.resolved, fields.count == fs.count {
				var df = 0 as u8
				instructions += try zip(fields, fs).reduce(into: []) { r, e in
					r += try eval(expr: e.1.1, type: e.0.type, offset: offset + df)
					df += u8(e.0.type.size)
				}
			} else if case let .array(t, cnt) = type.resolved, fs.count == cnt {
				var df = 0 as u8
				instructions += try fs.reduce(into: []) { r, e in
					r += try eval(expr: e.1, type: t, offset: offset + df)
					df += u8(t.size)
				}
			} else {
				throw err("Invalid tuple \(fs)")
			}
		default:
			throw err("Invalid expression \(expr)")
		}
		return instructions
	}
}

extension OPCode {
	func callAsFunction(x: u8, yz: u16) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(yz: i16(u: yz)))
	}
	func callAsFunction(x: u8, y: u8, z: u8) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(.init(y: i8(u: y), z: i8(u: z))))
	}
}
