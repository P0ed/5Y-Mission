import Foundation

struct Token {
	var line: Int
	var idx: Int
	var value: TokenValue
}

enum TokenValue {
	case hex(UInt32)
	case int(Int32)
	case float(Float)
	case string(String)
	case identifier(String)
	case symbol(String)
}

public extension UInt8 {
	var hexString: String { String(format: "%02x", self) }
}

public struct Typ {
	var name: String
	var signature: String
}

public indirect enum Expr {
	case consti(Int32)
	case constf(Float)
	case consts(String)
	case funktion(String?, [Stmt])
}

public indirect enum TypeExpr {
	case int, float, char, array(TypeExpr, Int?), named(String)
}

public indirect enum Stmt {
	case expr(Expr)
	case typeDecl(String, TypeExpr)
	case decl(Typ, String, Expr)
	case assignment(String, Expr)
}

public struct TreeParsingError: Error {
	public var description: String
}

public struct CompilationError: Error {
	public var description: String
}

final class Node<A> {
	var parent: Node<A>?
	var children: [Node<A>] = []
	var content: A

	init(parent: Node<A>?, children: [Node<A>], content: A) {
		self.parent = parent
		self.children = children
		self.content = content
	}
}
