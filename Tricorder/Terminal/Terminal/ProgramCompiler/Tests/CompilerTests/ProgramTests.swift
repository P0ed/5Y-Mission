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
		result = double(21)
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

	@Test func functionComposition() async throws {
		let program = """
		[ inc: int > int = \\x > x + 1;
		[ double: int > int = \\x > x * 2;
		[ result: int = 0;
		[ composed: int > int = double • inc;
		result = composed # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 12) // (5 + 1) * 2 = 12
	}

	@Test func closureAsParameter() async throws {
		let program = """
		[ apply: (int > int) > int > int = \\f > \\x > f # x;
		[ double: int > int = \\x > x * 2;
		[ applied: int > int = apply # double;
		[ result: int = 0;
		result = applied # 7
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[3] == 14)
	}

	@Test func nestedFunctions() async throws {
		let program = """
		[ outerFn: int > int = \\x > {
			[ innerFn: int > int = \\y > x * y;
			innerFn # 2
		};
		[ result: int = 0;
		result = outerFn # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 10) // 5 * 2
	}

	@Test func multiLevelNestedFunctions() async throws {
		let program = """
		[ level1: int > int = \\x > {
			[ level2: int > int = \\y > {
				[ level3: int > int = \\z > x * y * z;
				level3 # 3
			};
			level2 # 2
		};
		[ result: int = 0;
		result = level1 # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 30) // 5 * 2 * 3
	}

	@Test func returningNestedFunction() async throws {
		let program = """
		[ makeAdder: int > int > int = \\base > {
			\\x > base + x
		};
		[ add5: int > int = makeAdder # 5;
		[ result: int = 0;
		result = add5 # 10
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[2] == 15) // 5 + 10
	}

	@Test func multipleCaptureContexts() async throws {
		let program = """
		[ x: int = 10;
		[ y: int = 20;
		[ makeMultiplier: int > int > int = \\factor > {
			\\n > x * y * factor * n
		};
		[ multiply: int > int = makeMultiplier # 2;
		[ result: int = 0;
		result = multiply # 3
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[5] == 1200) // 10 * 20 * 2 * 3 = 1200
	}

	@Test func capturingMutableVariable() async throws {
		let program = """
		[ counter: int = 0;
		[ increment: int > int = \\step > {
			counter = counter + step;
			counter
		};
		[ first: int = increment # 1;
		[ second: int = increment # 2;
		[ third: int = increment # 3
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 1)  // First call returns 1
		#expect(result.registers[2] == 3)  // Second call returns 1+2=3
		#expect(result.registers[3] == 6)  // Third call returns 3+3=6
	}

	@Test func functionWithMultipleParameters() async throws {
		let program = """
		[ add3: int > int > int > int = \\a > \\b > \\c > a + b + c;
		[ partialAdd: int > int > int = add3 # 5;
		[ morePartial: int > int = partialAdd # 10;
		[ result: int = 0;
		result = morePartial # 15
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[3] == 30) // 5 + 10 + 15
	}

	@Test func nestedTypeWithClosure() async throws {
		let program = """
		: transformer = int > int;
		: processor = (input: int, transform: transformer);
		[ double: transformer = \\x > x * 2;
		[ process: processor = (input: 21, transform: double);
		[ result: int = 0;
		result = process.transform # process.input
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[4] == 42) // 21 * 2
	}

	@Test func recursiveFunction() async throws {
		let program = """
		[ sumToN: int > int = \\n > {
			[ result: int = 0;
			result = n == 0 ? 0 : n + sumToN # (n - 1);
			result
		};
		[ result: int = sumToN # 5
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[1] == 15) // 5 + 4 + 3 + 2 + 1 + 0 = 15
	}

	@Test func multipleClosuresDifferentTypes() async throws {
		let program = """
		[ strLen: char 32 > int = \\s > 5; // Simplified - just returns length 5
		[ intToStr: int > char 32 = \\i > "Number";
		[ processor: (int > char 32) > (char 32 > int) > int > int = \\f > \\g > \\x > {
			[ s: char 32 = f # x;
			g # s
		};
		[ result: int = 0;
		result = processor # intToStr # strLen # 42
		"""

		let scope = try Scope(program: program)
		let executable = try scope.compile()
		let result = try executable.run(scope: scope)

		#expect(result.registers[6] == 5) // intToStr converts 42 to "Number", strLen returns 5
	}

	private func c2i(_ char: Character) -> Int32 { char.asciiValue.map(Int32.init) ?? 0 }
}
