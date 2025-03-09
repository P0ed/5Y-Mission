import Foundation

func tokenize(line: Int, string: String) throws -> [Token] {
	let sc = Scanner(string: string)
	let ids = CharacterSet.letters.union(.decimalDigits).union(["_"])
	let symbols = CharacterSet(charactersIn: ";{:}(,).=<>+-*/%!~#&|")
	var tokens = [] as [Token]

	while !sc.isAtEnd {

		let c = string[sc.currentIndex]
		switch c {
		case _ where c.isLetter:
			let id = sc.scanCharacters(from: ids) ?? ""
			tokens.append(Token(line: line, idx: tokens.count, value: .identifier(id)))
		case _ where c.isNumber:
			let scidx = sc.currentIndex

			if let int = sc.scanInt(representation: .decimal) {
				tokens.append(Token(line: line, idx: tokens.count, value: .int(Int32(int))))
			} else {
				sc.currentIndex = scidx

				if let hex = sc.scanUInt64(representation: .hexadecimal) {
					tokens.append(Token(line: line, idx: tokens.count, value: .hex(UInt32(hex))))
				} else {
					sc.currentIndex = scidx

					if let float = sc.scanFloat(representation: .decimal) {
						tokens.append(Token(line: line, idx: tokens.count, value: .float(float)))
					} else {
						throw TreeParsingError(
							description: "Can't parse number '\(c)' at line: \(line) idx: \(tokens.count)"
						)
					}
				}
			}
		case "\"":
			_ = sc.scanCharacter()
			if let str = sc.scanUpToString("\"") {
				tokens.append(Token(line: line, idx: tokens.count, value: .string(str)))
				_ = sc.scanCharacter()
			} else {
				throw TreeParsingError(
					description: "Can't parse string literal '\(c)' at line: \(line) idx: \(tokens.count)"
				)
			}
		case _ where c.isWhitespace:
			string.indices.formIndex(after: &sc.currentIndex)
		default:
			if let symbols = sc.scanCharacters(from: symbols) {
				tokens += symbols.enumerated().map {
					Token(line: line, idx: tokens.count + $0, value: .symbol(String($1)))
				}
			} else {
				throw TreeParsingError(
					description: "Can't tokenize '\(c)' at line: \(line) idx: \(tokens.count)"
				)
			}
		}
	}

	return tokens
}
