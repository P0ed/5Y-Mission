import Foundation

struct Token: Hashable {
	var line: Int
	var idx: Int
	var value: TokenValue
}

enum TokenValue: Hashable {
	case hex(UInt32)
	case int(Int32)
	case float(Float)
	case string(String)
	case id(String)
	case symbol(String)
	case compound([Token])
	case tuple([Token])
}

public struct Scope {
	@Ref public var parent: Scope?
	public var types: [String: Typ]
	public var vars: [Var]
	public var exprs: [Expr]
}

public indirect enum Expr {
	case consti(Int32)
	case constu(UInt32)
	case constf(Float)
	case consts(String)
	case id(String)
	case variable(Var)
	case funktion(String?, [Expr])
	case assignment(Expr, Expr)
	case sum(Expr, Expr)
}

public indirect enum Typ: Hashable {
	case int, float, char, bool, void,
		 type(String, Typ),
		 array(Typ, Int),
		 tuple([VarDecl]),
		 pointer(Typ),
		 function(Typ, Typ)
}

public struct VarDecl: Hashable {
	var type: Typ
	var name: String
}

public struct CompilationError: Error, CustomStringConvertible {
	public var description: String
}

extension Token: CustomStringConvertible {
	public var description: String {
		"\(line):\(value)"
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

public extension Typ {

	var size: Int {
		switch self {
		case .int, .float, .char, .bool: 1
		case .void: 0
		case .pointer: 1
		case .function: 1
		case let .type(_, type): type.size
		case let .array(.char, len): (len + 3) / 4
		case let .array(.bool, len): (len + 31) / 32
		case let .array(type, len): type.size * len
		case let .tuple(tuple): tuple.map(\.type.size).reduce(0, +)
		}
	}

	var layout: String {
		switch self {
		case .int: "i"
		case .float: "f"
		case .char: "c"
		case .bool: "b"
		case .void: "v"
		case .pointer: "p"
		case let .function(o, i): o.layout + "<" + i.layout
		case let .type(_, type): type.layout
		case let .array(type, len): [String](repeating: type.layout, count: len).joined()
		case let .tuple(tuple): tuple.map(\.type.layout).joined()
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
		case let .function(o, i): "\(o) < \(i)"
		case let .type(name, _): "\(name)"
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

public struct Var {
	var offset: Int
	var type: Typ
	var name: String
}

@propertyWrapper
public final class Ref<A> {
	public var wrappedValue: A
	public init(wrappedValue: A) { self.wrappedValue = wrappedValue }
}

public extension Scope {
	var size: Int { vars.map(\.type.size).reduce(0, +) }
	var offset: Int { parent.map { $0.size + ($0.parent?.offset ?? 0) } ?? 0 }

//	var returnType: Typ {
////		exp
//	}
}
