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
		print # "Hello, World!"
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers.isEmpty)
		#expect(result.prints == "Hello, World!")
	}

	@Test func integerSubtraction() async throws {
		let program = """
		[ a: int = 100;
		[ b: int = 30;
		[ result: int = 0;
		result = a - b
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 70)
	}

	@Test func integerMultiplication() async throws {
		let program = """
		[ a: int = 7;
		[ b: int = 6;
		[ result: int = 0;
		result = a * b
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 42)
	}

	@Test func integerDivision() async throws {
		let program = """
		[ a: int = 100;
		[ b: int = 20;
		[ result: int = 0;
		result = a / b
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 5)
	}

	@Test func arrayDeclaration() async throws {
		let program = """
		: numbers = int 3;
		[ arr: numbers = (0, 1, 2)
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[0] == 0)
		#expect(result.registers[1] == 1)
		#expect(result.registers[2] == 2)
	}

	@Test func structDeclaration() async throws {
		let program = """
		: point = (x: int, y: int);
		[ p: point = (x: 10, y: 20)
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[0] == 10)
		#expect(result.registers[1] == 20)
	}

	@Test func multipleVariableDeclarations() async throws {
		let program = """
		[ a: int = 1;
		[ b: int = 2;
		[ c: int = 3;
		[ d: int = 4;
		[ sum: int = 0;
		sum = a + b + c + d
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[4] == 10)
	}

	@Test func simpleFunction() async throws {
		let program = """
		[ double: int > int = \\x > x * 2;
		[ result: int = 0;
		result = double # 21
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 42)
	}

	@Test func functionWithCompoundBody() async throws {
		let program = """
		[ process: int > int = \\x > {
			[ temp: int = x * 2;
			temp + 10
		};
		[ result: int = 0;
		result = process # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 20) // (5 * 2) + 10 = 20
	}

	@Test func functionComposition() async throws {
		let program = """
		[ inc: int > int = \\x > x + 1;
		[ double: int > int = \\x > x * 2;
		[ result: int = 0;
		result = double • inc # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 12) // (5 + 1) * 2 = 12
	}

	@Test func closureCapture() async throws {
		let program = """
		[ base: int = 10;
		[ add_to_base: int > int = \\x > base + x;
		[ result: int = 0;
		result = add_to_base # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 15)
	}

	@Test func closureAsParameter() async throws {
		let program = """
		[ apply: (int > int) > int > int = \\f > \\x > f # x;
		[ double: int > int = \\x > x * 2;
		[ result: int = 0;
		result = apply # double # 7
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 14)
	}

	@Test func stringDeclaration() async throws {
		let program = """
		: string = char 32;
		[ greeting: string = "Hello, Kung!"
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[0] & 0xFF == c2i("H"))
		#expect((result.registers[0] >> 8) & 0xFF == c2i("e"))
		#expect(result.registers[1] & 0xFF == c2i("o"))
	}

	@Test func printString() async throws {
		let program = """
		: string = char 32;
		[ greeting: string = "Testing!";
		print # greeting
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.prints == "Testing!")
	}

	@Test func characterLiteral() async throws {
		let program = """
		[ c: char = "A";
		[ value: int = 0;
		value = c
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == c2i("A"))
	}

	private func c2i(_ char: Character) -> Int32 { char.asciiValue.map(Int32.init) ?? 0 }
}
