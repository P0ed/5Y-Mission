import ProgramCompiler
import Machine

struct ExecutionResult {
	var registers: [Int32]
	var prints: String
}

struct ExecutionError: Error {
	var statusCode: Int
}

extension Program {
	private nonisolated(unsafe) static var prints = ""

	/// Runs the program, returns root scope variables and everything printed
	func run(scope: Scope) throws -> ExecutionResult {
		Self.prints = ""
		defer { Self.prints = "" }

		let ret = Machine.runProgram(
			instructions, u16(instructions.count),
			{ pc, inn in 0 },
			{ cString in Self.prints += cString.map { String(cString: $0) } ?? "" }
		)

		guard ret == 0 else { throw ExecutionError(statusCode: Int(ret)) }

		return ExecutionResult(
			registers: (u8.min..<u8(scope.size)).map { readRegister(0, $0) },
			prints: Self.prints
		)
	}
}
