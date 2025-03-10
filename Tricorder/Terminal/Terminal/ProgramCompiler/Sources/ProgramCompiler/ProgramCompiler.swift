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
		self = try buidTree(tokens: tokens)
	}

	func compile() throws -> Program {
		return Program(rawData: [
			Instruction(op: RXI, x: 0, y: 1, z: .max),
			Instruction(op: RXI, x: 1, y: 0, z: 2),
			Instruction(op: ADD, x: 0, y: 0, z: 1),
			Instruction(op: RET, x: 0, y: 0, z: 0)
		])

//		throw CompilationError(description: "Failed to compile tree: \(self)")
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
