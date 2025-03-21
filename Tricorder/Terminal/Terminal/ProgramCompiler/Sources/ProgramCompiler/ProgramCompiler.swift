import Foundation
import Machine

public extension OPCode {
	var name: String {
		switch self {
		case RXI: "RXI"
		case RXU: "RXU"
		case RXST: "RXST"
		case STRX: "STRX"
		case ADD: "ADD"
		case INC: "INC"
		case FN: "FN"
		case RET: "RET"
		default: rawValue.hexString
		}
	}
}

public extension Scope {

	init(program: String) throws {
		let tokens = try tokenize(program: program)
		self = .empty
		try buildTree(tokens: tokens)
	}

	func compile() throws -> Program {
		var instructions = [] as [Instruction]

		for expr in exprs {
			switch expr {
			case let .assignment(.variable(v), rhs):
				switch rhs {
				case let .consti(int): instructions += [
					RXI(x: UInt8(v.offset), yz: UInt16(int))
				]
				case let .variable(rv): instructions += [
					RXI(x: UInt8(rv.offset + rv.type.size), yz: UInt16(0)),
					ADD(x: UInt8(v.offset), y: UInt8(rv.offset + rv.type.size), z: UInt8(rv.offset))
				]
				case let .sum(lhs, rhs): instructions += try sum(UInt8(v.offset), v.type, lhs, rhs)
				default: throw CompilationError(description: "Unknown expression \(expr)")
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
		case let (.variable(v), .consti(c)): [
			RXI(x: ret + 1, yz: UInt16(c)),
			ADD(x: ret, y: UInt8(v.offset), z: ret + 1)
		]
		default: throw CompilationError(description: "Unknown sum")
		}
	}

//	private func eval(expr: Expr) throws -> [Instruction] {
//		
//	}
}

public struct Program {
	public var rawData: [Instruction]

	public init(rawData: [Instruction]) {
		self.rawData = rawData
	}
}

public extension Program {

	func run() -> Int32 {
		let len = Int32(rawData.count)
		Machine.loadProgram(rawData, len)
		if Machine.runFunction(0, 0) == 0 {
			return readRegister(0)
		} else {
			return -1
		}
	}
}

public extension Instruction {
	var description: String { "\(op.name) \(x.u.hexString) \(y.u.hexString) \(z.u.hexString)" }
}

extension UInt8 {
	var hexString: String { String(format: "%02x", self) }
}

extension OPCode {

	func callAsFunction(x: UInt8, yz: UInt16) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(yz: i16(u: yz)))
	}

	func callAsFunction(x: UInt8, y: UInt8, z: UInt8) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(.init(y: i8(u: y), z: i8(u: z))))
	}
}
