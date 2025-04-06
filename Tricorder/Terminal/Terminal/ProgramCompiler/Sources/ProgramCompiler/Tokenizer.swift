import Foundation

public extension String {

	func tokenized() throws -> [Token] {
		let tokens = try tokenize(self)
		let cmpnds = try compounds("{", "}", TokenValue.compound, tokens)
		let tuples = try compounds("(", ")", TokenValue.tuple, cmpnds)

		return tuples
	}
}

private func tokenize(_ string: String) throws -> [Token] {
	let sc = Scanner(string: string)
	let ids = CharacterSet.letters.union(.decimalDigits).union(["_"])
	let symbols = CharacterSet(charactersIn: ":;,\\{}()[].=<>+-*/%!~#&|?^'•")
	var tokens = [] as [Token]

	var line = 1
	var scidx = sc.currentIndex
	var range: NSRange {
		let location = scidx.utf16Offset(in: string)
		return .init(location: location, length: sc.currentIndex.utf16Offset(in: string) - location)
	}

	while !sc.isAtEnd {
		scidx = sc.currentIndex
		let c = string[scidx]

		switch c {
		case _ where c.isLetter:
			let id = sc.scanCharacters(from: ids) ?? ""
			tokens.append(Token(
				line: line,
				range: range,
				value: .id(id)
			))
		case _ where c.isNumber:
			if sc.scanString("0x") != nil {
				let hex = try sc.scanUInt64(representation: .hexadecimal)
					.unwraped("Can't parse hex '\(c)' at line: \(line) idx: \(tokens.count)")
				tokens.append(Token(
					line: line,
					range: range,
					value: .hex(UInt32(hex))
				))
			} else {
				sc.currentIndex = scidx

				if let int = sc.scanInt(representation: .decimal) {
					if sc.scanString(".") != nil {
						sc.currentIndex = scidx
						if let float = sc.scanFloat(representation: .decimal) {
							tokens.append(Token(
								line: line,
								range: range,
								value: .float(float)
							))
						} else {
							throw err("Can't parse float '\(c)' at line: \(line) idx: \(tokens.count)")
						}
					} else {
						tokens.append(Token(
							line: line,
							range: range,
							value: .int(Int32(int))
						))
					}
				} else {
					throw err("Can't parse int '\(c)' at line: \(line) idx: \(tokens.count)")
				}
			}
		case ";" where line != tokens.last?.line:
			if let comment = sc.scanUpToCharacters(from: .newlines) {
				tokens.append(Token(line: line, range: range, value: .comment(comment)))
			} else {
				throw err("Can't parse comment line '\(c)' at line: \(line) idx: \(tokens.count)")
			}
		case "\"":
			_ = sc.scanCharacter()
			if !sc.isAtEnd, string[sc.currentIndex] == "\"" {
				_ = sc.scanCharacter()
				tokens.append(Token(line: line, range: range, value: .string("")))
			} else if let str = sc.scanUpToString("\"") {
				_ = sc.scanCharacter()
				tokens.append(Token(line: line, range: range, value: .string(str)))
			} else {
				throw err("Can't parse string literal '\(c)' at line: \(line) idx: \(tokens.count)")
			}
		case _ where c.isNewline:
			line += 1
			fallthrough
		case _ where c.isWhitespace:
			string.indices.formIndex(after: &sc.currentIndex)
		default:
			if let symbols = sc.scanCharacters(from: symbols) {
				let r = range
				tokens += symbols.enumerated().map {
					Token(
						line: line,
						range: NSRange(location: r.location + $0, length: 1),
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
				throw err("Can't find matching bracket '\(begin)' for token \(token)")
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
		throw err("Can't find matching bracket '\(end)' for token \(tkn)")
	}

	return stk.flatMap { $0 }
}
