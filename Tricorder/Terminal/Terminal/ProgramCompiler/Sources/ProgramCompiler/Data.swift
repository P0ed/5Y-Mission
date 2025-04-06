import Machine

public indirect enum Typ: Hashable {
	case int, float, char, bool, void,
		 type(String, Typ),
		 array(Typ, Int),
		 tuple([Field]),
		 pointer(Typ),
		 function(Typ, Typ)
}

public struct Field: Hashable {
	var name: String
	var type: Typ
}

public struct Var: Hashable {
	public var offset: Int
	public var type: Typ
	public var name: String
}

public struct Func: Hashable {
	var offset: Int
	var type: Typ
	var name: String
	var id: Int
	var program: Program
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
