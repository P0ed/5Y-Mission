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
	var types: [String: Typ]
	var vars: [String: Var]
	var statements: [Stmt]
}

public indirect enum Stmt {
	case expr(Expr)
	case typeDecl(TypDecl)
	case varDecl(VarDecl)
	case assignment(Expr, Expr)
}

public indirect enum Expr {
	case consti(Int32)
	case constf(Float)
	case consts(String)
	case funktion(String?, [Stmt])
}

public struct Typ: Hashable {
	var name: String
	var layout: String
}

public indirect enum TypExpr {
	case type(Typ),
		 array(TypExpr, Int),
		 tuple([(String, TypExpr)])
}

public struct TypDecl {
	var name: String
	var value: TypExpr
}

public struct VarDecl {
	var type: Typ
	var name: String
	var value: Expr
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

public extension TypExpr {
	var layout: String {
		switch self {
		case let .type(type): type.layout
		case let .array(type, len): [String](repeating: type.layout, count: len).joined()
		case let .tuple(tuple): tuple.reduce("") { r, e in r + e.1.layout }
		}
	}
}

public extension UInt8 {
	var hexString: String { String(format: "%02x", self) }
}
