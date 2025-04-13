public final class Scope {
	public weak var parent: Scope?
	public var arrow: Arrow = .void => .void
	public var types: [String: Typ] = .default
	public var funcs: [Func] = []
	public var vars: [Var] = []
	public var closure: [Var] = []
	public var exprs: [Expr] = []
}

public extension [String: Typ] {
	static var `default`: Self {
		["int": .int, "float": .float, "char": .char, "bool": .bool, "void": .void]
	}
}

public extension Scope {

	var root: Scope { parent?.root ?? self }

	var size: Int {
		vars.map(\.type.size).reduce(arrow.o.size, +)
	}
	var offset: Int {
		parent.map { $0.size + ($0.parent?.offset ?? 0) } ?? 0
	}
	var temporary: UInt8 {
		.init(selector: .top, offset: UInt8(size))
	}

	func local(_ id: String) -> Var? {
		vars.first(where: { $0.name == id }) ?? closure.first(where: { $0.name == id })
	}

	func resolvedType(_ expr: TypeExpr) throws -> Typ {
		switch expr {
		case let .id(id): try types[id].unwraped("Unknown type \(id)")
		case let .arr(t, c): try .array(resolvedType(t), c)
		case let .fn(i, o): try .function(resolvedType(i) => resolvedType(o))
		case let .ptr(t): try .pointer(resolvedType(t))
		case let .tuple(fs): try .tuple(fs.map { try Field(name: $0.0, type: resolvedType($0.1)) })
		}
	}

	func inferredType(_ expr: Expr) throws -> Typ {
		let type: Typ? = switch expr {
		case .consti, .constu: .int
		case .constf: .float
		case let .consts(string): .array(.char, string.lengthOfBytes(using: .ascii))
		case let .id(name): local(name)?.type
		default: .none
		}
		return try type.unwraped("Can't infer type of \(expr)")
	}

	func typeDecl(_ id: String, _ type: TypeExpr) throws {
		guard types[id] == nil else { throw err("Redeclaration of \(id)") }
		types[id] = try .type(id, resolvedType(type))
	}

	func varDecl(_ id: String, _ type: TypeExpr, _ expr: Expr) throws {
		if vars.first(where: { $0.name == id }) == nil {
			let v = try Var(
				offset: vars.last.map { $0.offset + $0.type.size } ?? 0,
				type: resolvedType(type),
				name: id
			)
			vars.append(v)
		} else {
			throw err("Redeclaration of var \(id)")
		}
	}
}
