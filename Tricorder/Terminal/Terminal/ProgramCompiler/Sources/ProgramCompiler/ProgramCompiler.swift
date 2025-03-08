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

public extension Stmt {

	init(program: String) throws {

		func compounds(_ begin: String, _ end: String) -> (String) throws -> [Substring] {

			func compounds(_ program: String) throws -> [Substring] {
				let compoundsX = program.split(separator: begin)

				if compoundsX.count == 1 { return compoundsX }

				let compoundsXS = compoundsX[1].split(separator: end)
				if compoundsXS.count > 1 {
					return try compoundsX + compounds(String(compoundsXS[1]))
				} else {
					throw TreeParsingError(description: "Can't find matching bracket '\(end)':\n\(program)")
				}
			}

			return compounds
		}

		let lines = program.split(separator: "\n").enumerated()
		let codeLines = lines.filter { !$0.element.starts(with: "//") }

		let tokens = try codeLines.flatMap { line, value in
			try tokenize(line: line, string: String(value))
		}

		print("tokens", tokens, "\n")

		throw TreeParsingError(description: "Tokens:\n\(tokens.map(\.value))")
	}
}

public extension Stmt {

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

	func run() {
		Machine.loadProgram(rawData, Int32(rawData.count))
		Machine.runFunction(0)
		print("mem rx[0]: \(mem.rx.0)")
	}
}

public extension Instruction {
	var description: String { "\(op.name) \(x.hexString) \(y.hexString) \(z.hexString)" }
}
