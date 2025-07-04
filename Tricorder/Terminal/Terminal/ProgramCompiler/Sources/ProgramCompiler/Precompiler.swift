extension Scope {

	func precompile() throws {
		reloveComposition()
		indexFunctions()
		try declareTypes()
		try declareVariables()
		try declareFuncs()
		try inferTypes()
		try resolveInput()
		captureContext()
	}
}

private extension Scope {

	func reloveComposition() {
		traverseAll { e, s in
			if case let .binary(.comp, f, g) = e {
				let fs = Scope()
				fs.exprs = [.binary(.rcall, f, .binary(.rcall, g, .id("x")))]
				e = .funktion(0, ["x"], fs)
			}
		}
	}

	func indexFunctions() {
		var id = 0
		traverseAll { xpr, scope in
			if case let .funktion(_, labels, fs) = xpr {
				fs.parent = scope
				xpr = .funktion(id, labels, fs)
				id += 1
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
		try traverseExprs { e, s in
			if case let .varDecl(name, .fn, x) = e, case let .funktion(id, _, _) = x {
				if funcs.first(where: { $0.name == name }) != nil {
					throw err("Redeclaration of func \(id)")
				} else if let fn = funcs.firstIndex(where: { $0.id == id }) {
					funcs[fn].name = name
				} else {
					throw err("Function \(id) not found")
				}
			}
		}
	}

	func inferTypes() throws {
		try traverseExprs { e, s in
			if case let .varDecl(_, .fn(i, o), x) = e,
			   case let .funktion(_, _, fs) = x {
				fs.arrow = try resolvedType(i) => resolvedType(o)
			}
		}
		traverseAll { e, s in
			if case let .funktion(_, _, fs) = e,
			   case let .function(retType) = fs.arrow.o.resolved,
			   case let .funktion(_, _, ifs) = fs.exprs.last {
				ifs.arrow = retType
			}
		}
	}

	func resolveInput() throws {
		try traverseExprs { e, s in
			if case let .funktion(_, labels, fs) = e {
				if fs.arrow.i == .void, labels.isEmpty {} else if fs.arrow.i != .void, labels.count == 1 {
					fs.vars.append(Var(offset: fs.arrow.o.size, type: fs.arrow.i, name: labels[0]))
				} else {
					throw err("Invalid arg list \(arrow.i) \(labels)")
				}
			}
		}
	}

	func captureContext() {
		traverseAll { xpr, scope in
			if case let .funktion(_, _, fs) = xpr {
				fs.traverseExprs { x, xs in
					if case let .id(name) = x, xs.local(name) == nil, let v = scope.local(name) {
						let offset = fs.closure.map(\.type.size).reduce(0, +)
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
}
