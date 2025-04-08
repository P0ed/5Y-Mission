extension Scope {

	mutating func precompile() throws {
		try indexFunctions()
		try declareTypes()
		try declareVariables()
	}

	mutating func indexFunctions() throws {
		var id = 0
		exprs.mutate { xpr in
			if case .funktion(_, let labels, let exprs) = xpr {
				xpr = .funktion(id, labels, exprs)
				id += 1
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
}
