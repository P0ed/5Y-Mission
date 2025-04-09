public final class Scope {
	public weak var parent: Scope?
	public var arrow: Arrow = Arrow(i: .void, o: .void)
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
	var size: Int {
		vars.map(\.type.size).reduce(arrow.o.size, +)
	}
	var offset: Int {
		parent.map { $0.size + ($0.parent?.offset ?? 0) } ?? 0
	}
	var temporary: UInt8 {
		.init(selector: .top, offset: UInt8(size))
	}
	var root: Scope {
		parent ?? self
	}
	func local(_ id: String) -> Var? {
		vars.first(where: { $0.name == id }) ?? closure.first(where: { $0.name == id })
	}

	func resolvedType(_ expr: TypeExpr) throws -> Typ {
		switch expr {
		case let .id(id): try types[id].unwraped("Unknown type \(id)")
		case let .arr(t, c): try .array(resolvedType(t), c)
		case let .fn(i, o): try .function(Arrow(i: resolvedType(i), o: resolvedType(o)))
		case let .ptr(t): try .pointer(resolvedType(t))
		case let .tuple(fs): try .tuple(fs.map { try Field(name: $0.0, type: resolvedType($0.1)) })
		}
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

	func bindFunc(id: Int, name: String) throws {
		if funcs.first(where: { $0.name == name }) != nil {
			throw err("Redeclaration of func \(id)")
		} else if let fn = funcs.firstIndex(where: { $0.id == id }) {
			funcs[fn].name = name
		} else {
			throw err("Function \(id) not found")
		}
	}

	func funcDecl(id: Int, scope: Scope) throws {
//		if funcs.first(where: { $0.name == name }) != nil {
//			throw err("Redeclaration of func \(id)")
//		} else {
			//			if case .funktion(let fid, let labels, var scope) = expr {
//			scope.arrow = arrow

//			if arrow.i == .void, labels.isEmpty {} else if arrow.i != .void, labels.count == 1 {
//				scope.vars.append(Var(offset: arrow.o.size, type: arrow.i, name: labels[0]))
//			} else {
//				throw err("Invalid arg list \(arrow.i) \(labels)")
//			}

//				funcs.last.map { $0.offset + $0.program.instructions.count }
//			let f = 
//		} else {
//			throw err("Expected a function")
//		}
//		}
	}
}
