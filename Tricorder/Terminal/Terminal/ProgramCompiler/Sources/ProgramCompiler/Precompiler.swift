extension Scope {

	mutating func precompile() throws {
		try indexFunctions()
		try declareTypes()
		try declareVariables()
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
			if case .funktion(_, let labels, let fs) = xpr {

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
