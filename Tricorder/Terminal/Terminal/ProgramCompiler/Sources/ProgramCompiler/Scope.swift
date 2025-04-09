public struct Scope {
	public var parent: () -> Scope? = { nil }
	public var output: Typ = .void
	public var input: Typ = .void
	public var types: [String: Typ] = .default
	public var funcs: [Func] = []
	public var vars: [Var] = []
	public var exprs: [Expr] = []
}

public extension [String: Typ] {
	static var `default`: Self {
		["int": .int, "float": .float, "char": .char, "bool": .bool, "void": .void]
	}
}

public extension Scope {
	var size: Int { vars.map(\.type.size).reduce(output.size, +) }
	var offset: Int { parent().map { $0.size + ($0.parent()?.offset ?? 0) } ?? 0 }

	func local(_ id: String) -> Var? { vars.first(where: { $0.name == id }) }

	func resolvedType(_ expr: TypeExpr) throws -> Typ {
		switch expr {
		case let .id(id): try types[id].unwraped("Unknown type \(id)")
		case let .arr(t, c): try .array(resolvedType(t), c)
		case let .fn(i, o): try .function(resolvedType(i), resolvedType(o))
		case let .ptr(t): try .pointer(resolvedType(t))
		case let .tuple(fs): try .tuple(fs.map { try Field(name: $0.0, type: resolvedType($0.1)) })
		}
	}

	mutating func typeDecl(_ id: String, _ type: TypeExpr) throws {
		guard types[id] == nil else { throw err("Redeclaration of \(id)") }
		types[id] = try .type(id, resolvedType(type))
	}

	mutating func varDecl(_ id: String, _ type: TypeExpr, _ expr: Expr) throws {
		if vars.first(where: { $0.name == id }) == nil {
			let v = try Var(
				offset: vars.last.map { $0.offset + $0.type.size } ?? 0,
				type: resolvedType(type),
				name: id
			)
			vars.append(v)

			if case let .function(i, o) = v.type {
				try funcDecl(id, i, o, expr)
			}
		} else {
			throw err("Redeclaration of var \(id)")
		}
	}

	mutating func funcDecl(_ id: String, _ i: Typ, _ o: Typ, _ expr: Expr) throws {
		if funcs.first(where: { $0.name == id }) == nil {
			if case .funktion(let fid, let labels, var scope) = expr {
				scope.input = i
				scope.output = o

				if i == .void, labels.isEmpty {

				} else if i != .void, labels.count == 1 {
					scope.vars.append(Var(offset: o.size, type: i, name: labels[0]))
				} else {
					throw err("Invalid arg list \(i) \(labels)")
				}

				let f = Func(
					offset: funcs.last.map { $0.offset + $0.program.instructions.count } ?? 0,
					type: .function(i, o),
					name: id,
					id: fid,
					program: try scope.compile()
				)
				funcs.append(f)
			} else {
				throw err("Expected a function")
			}
		} else {
			throw err("Redeclaration of func \(id)")
		}
	}
}
