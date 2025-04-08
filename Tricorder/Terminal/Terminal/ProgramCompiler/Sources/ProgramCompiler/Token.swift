import Foundation

public struct Token: Hashable {
	public var line: Int
	public var range: NSRange
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
	case comment(String)
}

public extension Token {

	var lexeme: String {
		switch value {
		case let .hex(u): "0x\(u.hex)"
		case let .int(s): "\(s)"
		case let .float(f): "\(f)"
		case let .string(s): s
		case let .id(id): id
		case let .symbol(s): s
		case let .compound(tks): tks.map(\.lexeme).joined()
		case let .tuple(tks): tks.map(\.lexeme).joined()
		case let .comment(comment): comment
		}
	}

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
