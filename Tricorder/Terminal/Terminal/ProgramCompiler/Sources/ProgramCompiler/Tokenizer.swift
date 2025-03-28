import Foundation

func tokenize(program: String) throws -> [Token] {
	let lines = program
		.split(separator: "\n", omittingEmptySubsequences: false)
		.enumerated()
		.map {
			($0 + 1, String(String($1).split(
				separator: "//",
				omittingEmptySubsequences: false
			)[0]))
		}

	let tokens = try lines.flatMap { line, value in
		try tokenize(line: line, string: value)
	}

	let cmpnds = try compounds("{", "}", TokenValue.compound, tokens)
	let tuples = try compounds("(", ")", TokenValue.tuple, cmpnds)

	return tuples
}

private func tokenize(line: Int, string: String) throws -> [Token] {
	let sc = Scanner(string: string)
	let ids = CharacterSet.letters.union(.decimalDigits).union(["_"])
	let symbols = CharacterSet(charactersIn: ":;,\\{}()[].=<>+-*/%!~#&|?^'")
	var tokens = [] as [Token]

	while !sc.isAtEnd {
		let scidx = sc.currentIndex
		let c = string[scidx]

		switch c {
		case _ where c.isLetter:
			let id = sc.scanCharacters(from: ids) ?? ""
			tokens.append(Token(
				line: line,
				idx: scidx.utf16Offset(in: string),
				value: .id(id)
			))
		case _ where c.isNumber:
			if sc.scanString("0x") != nil {
				let hex = try sc.scanUInt64(representation: .hexadecimal)
					.unwraped("Can't parse hex '\(c)' at line: \(line) idx: \(tokens.count)")
				tokens.append(Token(line: line, idx: scidx.utf16Offset(in: string), value: .hex(UInt32(hex))))
			} else {
				sc.currentIndex = scidx

				if let int = sc.scanInt(representation: .decimal) {
					if sc.scanString(".") != nil {
						sc.currentIndex = scidx
						if let float = sc.scanFloat(representation: .decimal) {
							tokens.append(Token(line: line, idx: scidx.utf16Offset(in: string), value: .float(float)))
						} else {
							throw err("Can't parse float '\(c)' at line: \(line) idx: \(tokens.count)")
						}
					} else {
						tokens.append(Token(line: line, idx: scidx.utf16Offset(in: string), value: .int(Int32(int))))
					}
				} else {
					throw err("Can't parse int '\(c)' at line: \(line) idx: \(tokens.count)")
				}
			}
		case "\"":
			_ = sc.scanCharacter()
			if let str = sc.scanUpToString("\"") {
				tokens.append(Token(line: line, idx: scidx.utf16Offset(in: string), value: .string(str)))
				_ = sc.scanCharacter()
			} else {
				throw CompilationError(
					description: "Can't parse string literal '\(c)' at line: \(line) idx: \(tokens.count)"
				)
			}
		case _ where c.isWhitespace:
			string.indices.formIndex(after: &sc.currentIndex)
		default:
			if let symbols = sc.scanCharacters(from: symbols) {
				tokens += symbols.enumerated().map {
					Token(
						line: line,
						idx: scidx.utf16Offset(in: string) + $0,
						value: .symbol(String($1))
					)
				}
			} else {
				throw CompilationError(
					description: "Can't tokenize '\(c)' at line: \(line) idx: \(tokens.count)"
				)
			}
		}
	}

	return tokens
}

private func compounds(_ begin: String, _ end: String, _ make: ([Token]) -> TokenValue, _ tokens: [Token]) throws -> [Token] {
	let stk: [[Token]] = try tokens.reduce(into: [[]]) { stk, token in
		if token.value == .symbol(begin) {
			stk += [[]]
		} else if token.value == .symbol(end) {
			guard stk.count > 1 else {
				throw CompilationError(
					description: "Can't find matching bracket '\(begin)' for token \(token)"
				)
			}

			var t = token
			t.value = make(stk.removeLast())
			stk[stk.count - 1] += [t]
		} else {
			stk[stk.count - 1] += [token]
		}
	}

	guard stk.count == 1 else {
		let tkn = (stk.first?.first ?? tokens.last).map(String.init(describing:)) ?? ""
		throw CompilationError(
			description: "Can't find matching bracket '\(end)' for token \(tkn)"
		)
	}

	return stk.flatMap { $0 }
}
