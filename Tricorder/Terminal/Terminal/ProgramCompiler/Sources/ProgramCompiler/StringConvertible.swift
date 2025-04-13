import Machine

extension OPCode: @retroactive CustomStringConvertible {
	public var description: String {
		switch self {
		case RXI: 	" RXI"
		case RXU: 	" RXU"
		case RXRX:	"RXRX"
		case RXST: 	"RXST"
		case STRX: 	"STRX"
		case ADD: 	" ADD"
		case SUB:	" SUB"
		case INC: 	" INC"
		case MUL: 	" MUL"
		case DIV:	" DIV"
		case MOD:	" MOD"
		case PRNT:	"PRNT"
		case CLMK: 	"CLMK"
		case CLRT: 	"CLRT"
		case CLRL: 	"CLRL"
		case AUX:	" AUX"
		case FN: 	"  FN"
		case FNRX: 	"FNRX"
		case RET: 	" RET"
		case BREK:	"BREK"
		default: rawValue.hex
		}
	}
}

extension Instruction: @retroactive CustomStringConvertible {
	public var description: String { "\(op) \(x.u.hex) \(y.u.hex) \(z.u.hex)" }

	public func description(at idx: Int) -> String { "\(idx.fmt("%02d")): \t\(description)" }
}

extension Function: @retroactive CustomStringConvertible {
	public var description: String { "addr: \(address) closure: \(closure)" }
}

extension Arrow: CustomStringConvertible {
	public var description: String { "\(i) > \(o)" }
}

extension Program: CustomStringConvertible {
	public var description: String {
		instructions.enumerated().map { idx, inn in inn.description(at: idx) }.joined(separator: "\n")
	}
}

extension Func: CustomStringConvertible {
	public var description: String {
		"\(offset.fmt("%2d")) \t\(name): \(scope.arrow)\n\(scope.exprs.description)"
	}
}

extension [Expr] {
	public var description: String { map(String.init(describing:)).joined(separator: "; ") }
}

extension Var: CustomStringConvertible {
	public var description: String { "\(offset.fmt("%2d")) \t\(name): \(type)" }
}

extension Token: CustomStringConvertible {
	public var description: String { "\(line): \(value)" }
}

extension Expr: CustomStringConvertible {
	public var description: String {
		switch self {
		// Literal
		case let .consti(c): "\(c)"
		case let .constu(c): String(format: "%04X", c)
		case let .constf(c): "\(c)f"
		case let .consts(c): "\"\(c)\""
		
		case let .id(id): "\(id)"
		case let .tuple(fs): "(\(fs))"
		case let .typDecl(id, t): ".typDecl \(id): \(t)"
		case let .varDecl(id, t, e): ".varDecl \(id): \(t) = \(e)"
		case let .funktion(fid, l, fs):
			"\(fid): [\(fs.arrow)] \\\(l.joined(separator: ", ")) > { \(fs.exprs.description) }"
		case let .binary(.assign, l, r): "\(l) = \(r)"
		case let .binary(.rcall, l, r): "\(l) # \(r)"
		case let .binary(.comp, l, r): "\(l) • \(r)"

		case let .binary(.sum, l, r): "\(l) + \(r)"
		case let .binary(.sub, l, r): "\(l) - \(r)"
		case let .binary(.mul, l, r): "\(l) * \(r)"
		case let .binary(.div, l, r): "\(l) / \(r)"
		case let .binary(.mod, l, r): "\(l) % \(r)"
		// Logical
		case let .binary(.or, l, r): "\(l) | \(r)"
		case let .binary(.and, l, r): "\(l) & \(r)"
		case let .binary(.not, _, r): "!\(r)"
		// Comparison
		case let .binary(.eq, l, r): "\(l) == \(r)"
		case let .binary(.neq, l, r): "\(l) != \(r)"
		case let .binary(.gt, l, r): "\(l) > \(r)"
		case let .binary(.gte, l, r): "\(l) >= \(r)"
		case let .binary(.lt, l, r): "\(l) < \(r)"
		case let .binary(.lte, l, r): "\(l) <= \(r)"
		// Control flow
		case let .binary(.ctrl, l, r): "\(l) ? \(r)"
		// Unary
		case let .binary(.deref, _, r): "*\(r)"
		case let .binary(.ref, _, r): "&\(r)"
		case let .binary(.neg, _, r): "-\(r)"
		// Postfix
		case let .binary(.call, l, r): "\(l)(\(r))"
		case let .binary(.dot, l, r): "\(l).\(r)"
		case let .binary(.index, l, r): "\(l)[\(r)]"
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
		case let .tuple(fs): "(\(fs.map { $0.isEmpty ? "\($1)" : "\($0): \($1)" }.joined(separator: ", ")))"
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
		case let .function(io): "\(io.i) > \(io.o)"
		case let .type(name, _): name
		case let .array(type, len): "\(type.description)[\(len)]"
		case let .tuple(tuple): "(\(tuple.map { $0.name.isEmpty ? "\($0.type)" : "\($0.name): \($0.type)" }.joined(separator: ", ")))"
		}
	}
}

extension [Token] {

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

public extension Numeric where Self: CVarArg {
	var hex: String { fmt("%0\(MemoryLayout<Self>.size * 2)X") }
	func fmt(_ fmt: String) -> String { String(format: fmt, self) }
}
