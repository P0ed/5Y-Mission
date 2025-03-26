import Machine

extension Instruction: @retroactive CustomStringConvertible {
	public var description: String { "\(op) \(x.u.hexString) \(y.u.hexString) \(z.u.hexString)" }
}

extension Program: CustomStringConvertible {
	public var description: String {
		rawData.map(\.description).joined(separator: "\n")
	}
}

extension Func: CustomStringConvertible {
	public var description: String { "#\(offset) \(name): \(type)\n\(program)" }
}

extension Var: CustomStringConvertible {
	public var description: String { "#\(offset) \(name): \(type)" }
}

extension Token: CustomStringConvertible {
	public var description: String {
		"\(line):\(value)"
	}
}

extension Expr: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .consti(c): ".consti \(c)"
		case let .constu(c): ".constu \(c)"
		case let .constf(c): ".constf \(c)"
		case let .consts(c): ".consts \(c)"
		case let .id(id): ".id \(id)"
		case let .typDecl(id, t): ".typDecl \(id): \(t)"
		case let .varDecl(id, t, e): ".varDecl \(id): \(t) = \(e)"
		case let .funktion(l, es): "\\\(l.joined(separator: ", ")) > { \(es) }"
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

	public var resolvedDescription: String {
		switch self {
		case let .type(_, type): "\(type)"
		default: description
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
