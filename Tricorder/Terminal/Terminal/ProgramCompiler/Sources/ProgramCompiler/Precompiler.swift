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
				for xr in fs.exprs {
					if case let .id(name) = xr {
						if fs.local(name) == nil, let v = scope.local(name) {
							let offset = fs.closure.map(\.type.size).reduce(0, +)
							fs.closure.append(Var(offset: offset, type: v.type, name: name, selector: 1))
						}
					}
					xr.findReferencesTo(inParent: scope, ofScope: fs, addingTo: &fs.closure)
				}
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
