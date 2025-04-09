extension Scope {

	func precompile() throws {
		try indexFunctions()
		try declareTypes()
		try declareVariables()
		try collectCaptureList()
		try declareFuncs()
	}
}

private extension Scope {

	func indexFunctions() throws {
		var id = 0
		traverseAll { xpr, scope in
			if case let .funktion(_, labels, fs) = xpr {
				fs.parent = scope
				xpr = .funktion(id, labels, fs)
				id += 1
			}
		}
	}

	func collectCaptureList() throws {
		traverseAll { xpr, scope in
			if case let .funktion(_, _, fs) = xpr {
				fs.traverseExprs { x, xs in
					if case let .id(name) = x, xs.local(name) == nil, let v = scope.local(name) {
						let offset = closure.map(\.type.size).reduce(0, +)
						fs.closure.append(Var(
							offset: offset,
							type: v.type,
							name: name,
							selector: .closure
						))
					}
				}
			}
		}
	}

	func declareTypes() throws {
		try exprs.forEach {
			if case let .typDecl(id, t) = $0 { try typeDecl(id, t) }
		}
	}

	func declareVariables() throws {
		try exprs.forEach {
			if case let .varDecl(id, t, e) = $0 { try varDecl(id, t, e) }
		}
	}

	func declareFuncs() throws {
		traverseLeavesFirst { e, s in
			if case let .funktion(id, _, fs) = e {
				s.root.funcs.append(Func(
					offset: 0,
					id: id,
					name: "",
					scope: fs
				))
			}
		}

		var bindings = [] as [Expr]
		traverseExprs { e, s in
			if case .varDecl = e { bindings.append(e) }
		}
		try bindings.forEach { e in
			if case let .varDecl(name, .fn(i, o), x) = e, case let .funktion(id, labels, fs) = x {
				if funcs.first(where: { $0.name == name }) != nil {
					throw err("Redeclaration of func \(id)")
				} else if let fn = funcs.firstIndex(where: { $0.id == id }) {
					funcs[fn].name = name
					fs.arrow.i = try resolvedType(i)
					fs.arrow.o = try resolvedType(o)

					if fs.arrow.i == .void, labels.isEmpty {} else if fs.arrow.i != .void, labels.count == 1 {
						fs.vars.append(Var(offset: fs.arrow.o.size, type: fs.arrow.i, name: labels[0]))
					} else {
						throw err("Invalid arg list \(arrow.i) \(labels)")
					}
				} else {
					throw err("Function \(id) not found")
				}
			} else {
				throw err("Expected a function")
			}
		}
	}
}
