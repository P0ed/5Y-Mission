import Foundation
import Machine

public struct Token: Hashable {
	public var line: Int
	public var idx: Int
	public var value: TokenValue
}

public enum TokenValue: Hashable {
	case hex(UInt32)
	case int(Int32)
	case float(Float)
	case string(String)
	case id(String)
	case symbol(String)
	case compound([Token])
	case tuple([Token])
}

public struct Func: Hashable {
	var offset: Int
	var type: Typ
	var name: String
	var id: Int
	var program: Program
}

public indirect enum Expr {
	case consti(Int32),
		 constu(UInt32),
		 constf(Float),
		 consts(String),
		 id(String),
		 tuple([(String, Expr)]),
		 typDecl(String, TypeExpr),
		 varDecl(String, TypeExpr, Expr),
		 funktion(Int, [String], [Expr]),
		 assignment(Expr, Expr),
		 call(Expr, Expr),
		 sum(Expr, Expr),
		 delta(Expr, Expr),
		 mul(Expr, Expr),
		 div(Expr, Expr)
}

public indirect enum TypeExpr {
	case id(String),
		 arr(TypeExpr, Int),
		 fn(TypeExpr, TypeExpr),
		 ptr(TypeExpr),
		 tuple([(String, TypeExpr)])
}

public indirect enum Typ: Hashable {
	case int, float, char, bool, void,
		 type(String, Typ),
		 array(Typ, Int),
		 tuple([Field]),
		 pointer(Typ),
		 function(Typ, Typ)
}

public struct Var: Hashable {
	public var offset: Int
	public var type: Typ
	public var name: String
}

public struct Field: Hashable {
	var name: String
	var type: Typ
}

public struct CompilationError: Error, CustomStringConvertible {
	public var description: String
}

public extension Typ {

	var resolved: Typ {
		if case let .type(_, t) = self { return t } else { return self }
	}

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
		case let .function(i, o): i.layout + ">" + o.layout
		case let .type(_, type): type.layout
		case let .array(type, len): [String](repeating: type.layout, count: len).joined()
		case let .tuple(tuple): tuple.map(\.type.layout).joined()
		}
	}
}

extension Instruction: @retroactive Hashable {

	public static func == (lhs: Instruction, rhs: Instruction) -> Bool {
		lhs.op == rhs.op && lhs.x.u == rhs.x.u && lhs.yz.u == rhs.yz.u
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(op.rawValue)
		hasher.combine(x.u)
		hasher.combine(yz.u)
	}
}

extension Token {

	var symbol: String? {
		if case let .symbol(v) = value { return v }
		return nil
	}
	var int: Int32? {
		if case let .int(v) = value { return v }
		return nil
	}
	var hex: UInt32? {
		if case let .hex(v) = value { return v }
		return nil
	}
	var str: String? {
		if case let .string(v) = value { return v }
		return nil
	}
	var id: String? {
		if case let .id(v) = value { return v }
		return nil
	}
	var compound: [Token]? {
		if case let .compound(v) = value { return v }
		return nil
	}
	var tuple: [Token]? {
		if case let .tuple(v) = value { return v }
		return nil
	}
}
