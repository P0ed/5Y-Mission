import Machine

extension OPCode: @retroactive CustomStringConvertible {
	public var description: String {
		switch self {
		case RXI: 	"RXI "
		case RXU: 	"RXU "
		case RXST: 	"RXST"
		case STRX: 	"STRX"
		case ADD: 	"ADD "
		case INC: 	"INC "
		case MUL: 	"MUL "
		case FN: 	"FN  "
		case FNRX: 	"FNRX"
		case RET: 	"RET "
		default: rawValue.hexString
		}
	}
}

extension Instruction: @retroactive CustomStringConvertible {
	public var description: String { "\(op) \(x.u.hexString) \(y.u.hexString) \(z.u.hexString)" }
}

extension Function: @retroactive CustomStringConvertible {
	public var description: String { "addr: \(address) closure: \(closure) aux: \(aux)" }
}

extension Program: CustomStringConvertible {
	public var description: String {
		rawData.enumerated().map(Self.instructionDescription).joined(separator: "\n")
	}
	public static func instructionDescription(idx: Int, inn: Instruction) -> String {
		"\(String(format: "%02d", idx)): \t\(inn)"
	}
}

extension Func: CustomStringConvertible {
	public var description: String { "\(String(format: "%2d", offset)) \t\(name): \(type)\n\(program)" }
}

extension Var: CustomStringConvertible {
	public var description: String { "\(String(format: "%2d", offset)) \t\(name): \(type)" }
}

extension Token: CustomStringConvertible {
	public var description: String { "\(line): \(value)" }
}

extension Expr: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .consti(c): "\(c)"
		case let .constu(c): String(format: "%04X", c)
		case let .constf(c): "\(c)f"
		case let .consts(c): "\"\(c)\""
		case let .id(id): "`\(id)`"
		case let .tuple(fs): "(\(fs))"
		case let .typDecl(id, t): ".typDecl \(id): \(t)"
		case let .varDecl(id, t, e): ".varDecl \(id): \(t) = \(e)"
		case let .funktion(fid, l, es):
			"\(fid): \\`\(l.joined(separator: "`, `"))` > { \(es) }"
		case let .assignment(l, r): "\(l) = \(r)"
		case let .call(l, r): "\(l) # \(r)"
		case let .sum(l, r): "\(l) + \(r)"
		case let .delta(l, r): "\(l) - \(r)"
		case let .mul(l, r): "\(l) * \(r)"
		case let .div(l, r): "\(l) / \(r)"
		}
	}
}

extension TypeExpr: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .id(id): "\(id)"
		case let .arr(t, c): "\(t)[\(c)]"
		case let .fn(i, o): "\(i) > \(o)"
		case let .ptr(t): "\(t) *"
		case let .tuple(fs): "(\(fs.map { "\($0): \($1)" }.joined(separator: ", ")))"
		}
	}
}

extension Typ: CustomStringConvertible {

	public var description: String {
		switch self {
		case .int: "int"
		case .float: "float"
		case .char: "char"
		case .bool: "bool"
		case .void: "void"
		case let .pointer(t): "ptr<\(t)>"
		case let .function(i, o): "\(i) > \(o)"
		case let .type(name, _): name
		case let .array(type, len): "\(type.description)[\(len)]"
		case let .tuple(tuple): "(\(tuple.map { "\($0.name): \($0.type)" }.joined(separator: ", ")))"
		}
	}
}

extension Array where Element == Token {

	var description: String {
		isEmpty ? "[]" : "line: \(self[0].line) [" + map(\.value)
			.map(String.init(describing:))
			.joined(separator: ", ") + "]"
	}

	var line: Int { isEmpty ? 0 : self[0].line }
}

extension Scope: CustomStringConvertible {
	public var description: String {
		let types = types.map { ($0.key, $0.value) }
			.sorted { $0.0 < $1.0 }
			.map { "\t\($0): \($1.resolved)" }
			.joined(separator: "\n")
		let funcs = funcs
			.map { "\t\($0.description.aligned.aligned)" }
			.joined(separator: "\n")
		let vars = vars
			.map { "\t\($0)" }
			.joined(separator: "\n")
		let exprs = exprs
			.map { "\t\($0)" }
			.joined(separator: "\n")

		return "types:\n\(types)\n\nfuncs:\n\(funcs)\n\nvars:\n\(vars)\n\nexprs:\n\(exprs)"
	}
}

public extension String {
	var aligned: String { replacingOccurrences(of: "\n", with: "\n\t") }
}

extension UInt8 { var hexString: String { String(format: "%02X", self) } }
