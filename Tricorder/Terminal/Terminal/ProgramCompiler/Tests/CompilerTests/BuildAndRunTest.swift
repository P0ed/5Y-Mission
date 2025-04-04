import Testing
import ProgramCompiler
import Machine

struct Test {

	@Test func buildAndRun() async throws {
		let program = """
		[ count: int = 0;
		count = count + 1
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()

		let result = executable.run(
			meta: scope,
			breakpoint: { pc, inn in 0 },
			print: { x in print(x) }
		)

		#expect(result == 0)
	}
}
