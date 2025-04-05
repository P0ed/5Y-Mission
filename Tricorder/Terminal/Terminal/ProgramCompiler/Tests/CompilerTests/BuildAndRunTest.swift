import Testing
import ProgramCompiler
import Machine

@Suite(.serialized)
struct Test {

	@Test func integerAddition() async throws {
		let program = """
		[ count: int = 0;
		[ inc: int = 1;
		count = count + inc
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[0] == 1)
	}

	@Test func helloWorld() async throws {
		let program = """
		print # "Hello World!"
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers.isEmpty)
		#expect(result.prints == "Hello World!")
	}
}

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
			registers: (u8.min..<u8(scope.size)).map(readRegister),
			prints: Self.prints
		)
	}
}
