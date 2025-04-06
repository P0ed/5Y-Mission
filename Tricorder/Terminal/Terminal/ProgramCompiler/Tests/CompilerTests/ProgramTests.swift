import Testing
import ProgramCompiler

@Suite(.serialized)
struct ProgramTests {

	@Test func integerAddition() async throws {
		let program = """
		[ count: int = 100;
		[ inc: int = 10;
		count = count + inc
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers.count == 2)
		#expect(result.registers[0] == 110)
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
