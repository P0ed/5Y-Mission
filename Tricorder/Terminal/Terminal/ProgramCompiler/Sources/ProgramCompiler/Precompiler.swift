extension Scope {

	mutating func precompile() throws {
		try indexFunctions()
		try declareTypes()
		try declareVariables()
		try collectCaptureList()
		try declareFuncs()
	}
}

private extension Scope {

	mutating func indexFunctions() throws {
		var id = 0
		traverse { xpr, scope in
			if case .funktion(_, let labels, var fs) = xpr {
				fs.parent = { scope }
				xpr = .funktion(id, labels, fs)
				id += 1
			}
		}
	}

	mutating func collectCaptureList() throws {
		traverse { xpr, scope in
			if case .funktion(let funcId, let labels, var fs) = xpr {
				var closure = [] as [Var]
				fs.traverseExprs { x, xs in
					if case let .id(name) = x {
						if xs.local(name) == nil, let v = scope.local(name) {
							let offset = closure.map(\.type.size).reduce(0, +)
							closure.append(Var(offset: offset, type: v.type, name: name, selector: .closure))
						}
					}
				}
				fs.closure = closure
				xpr = .funktion(funcId, labels, fs)
			}
		}
	}

	mutating func declareTypes() throws {
		try exprs.forEach {
			if case let .typDecl(id, t) = $0 { try typeDecl(id, t) }
		}
	}

	mutating func declareVariables() throws {
		try exprs.forEach {
			if case let .varDecl(id, t, e) = $0 { try varDecl(id, t, e) }
		}
	}

	mutating func declareFuncs() throws {
		try exprs.forEach {
			if case let .varDecl(id, .fn(i, o), x) = $0 {
				try funcDecl(id, resolvedType(i), resolvedType(o), x)
			}
		}
	}
}
