import Machine

public indirect enum Typ: Hashable {
	case int, float, char, bool, void,
		 type(String, Typ),
		 array(Typ, Int),
		 tuple([Field]),
		 pointer(Typ),
		 function(Arrow)
}

public struct Field: Hashable {
	var name: String
	var type: Typ
}

public struct Var: Hashable {
	public var offset: Int
	public var type: Typ
	public var name: String
	public var selector: UInt8 = .top
}

public extension Var {
	var register: u8 { .init(selector: selector, offset: u8(offset)) }
}

public struct Arrow: Hashable {
	public var i: Typ
	public var o: Typ
}

public struct Func {
	var offset: Int
	var id: Int
	var name: String
	unowned var scope: Scope
}

public struct CompilationError: Error, CustomStringConvertible {
	public var description: String
}

public extension Typ {

	var resolved: Typ {
		if case let .type(_, t) = self { return t.resolved }
		if case let .tuple(f) = self, f.count == 1, f[0].name.isEmpty { return f[0].type.resolved }
		return self
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

public struct Program: Hashable {
	public var instructions: [Instruction]

	public init(instructions: [Instruction]) {
		self.instructions = instructions
	}
}

extension u8 {
	init(selector: u8, offset: u8) {
		self = selector << 6 | offset & 0x3F
	}
	var selector: u8 { self >> 6 }
	var offset: u8 { self & 0x3F }

	static var top: u8 { 0b00 }
	static var closure: u8 { 0b01 }
	static var aux: u8 { 0b10 }
	static var bottom: u8 { 0b11 }
}

infix operator =>
func => (input: Typ, output: Typ) -> Arrow { Arrow(i: input, o: output) }
