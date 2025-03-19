import Foundation
import Machine

public extension OPCode {
	var name: String {
		switch self {
		case RXI: "RXI"
		case RXU: "RXU"
		case RXRX: "RXRX"
		case RXST: "RXST"
		case STRX: "STRX"
		case STI: "STI"
		case STU: "STU"
		case POP: "POP"
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
			case let .assignment(lhs, rhs):
				_ = lhs
				_ = rhs
				break
			default:
				break
			}
		}

		instructions += [Instruction(op: RET, x: 0, y: 0, z: 0)]
		return Program(rawData: instructions)
	}
}

public struct Program {
	public var rawData: [Instruction]

	public init(rawData: [Instruction]) {
		self.rawData = rawData
	}
}

public extension Program {

	func run() -> Int32 {
		Machine.loadProgram(rawData, Int32(rawData.count))
		Machine.runFunction(0)
		return mem.rx.0
	}
}

public extension Instruction {
	var description: String { "\(op.name) \(x.hexString) \(y.hexString) \(z.hexString)" }
}
