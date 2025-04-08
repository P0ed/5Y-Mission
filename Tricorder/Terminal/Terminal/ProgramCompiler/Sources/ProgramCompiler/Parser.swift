struct Parser {
	var tokens: [Token]
	var j: Int = 0
}

extension Parser {

	var isAtEnd: Bool { j == tokens.count }
	var prev: Token { tokens[j - 1] }
	var current: Token { tokens[j] }

	func symbols(_ symbols: [String]) -> (Token) -> String? {
		{ symbols.map(TokenValue.symbol).contains($0.value) ? $0.symbol : nil }
	}

	mutating func match<A>(_ predicate: (Token) -> A?) -> A? {
		if !isAtEnd, let m = predicate(current) { advance(); return m }
		return nil
	}

	mutating func collect<A>(_ predicate: (Token) -> A?) throws -> [A] {
		.make {
			while let m = match(predicate) { $0.append(m) }
		}
	}

	@discardableResult
	mutating func consume<A>(_ predicate: (Token) -> A?, _ msg: String) throws -> A {
		try match(predicate).unwraped("\(msg)\n\(j): \(tokens)")
	}

	@discardableResult
	mutating func advance() -> Token {
		if !isAtEnd { j += 1 }
		return prev
	}

	mutating func binary(
		expr: (inout Parser) throws -> Expr,
		rhs: Optional<(inout Parser) throws -> Expr> = nil,
		map: [String: (Expr, Expr) -> Expr]
	) throws -> Expr {
		var l = try expr(&self)

		let predicate = symbols(map.map { $0.key })
		while let symbol = match(predicate) {
			let r = try rhs?(&self) ?? expr(&self)
			l = try map[symbol].unwraped("Unknown symbol: \(symbol)")(l, r)
		}
		return l
	}
}

extension Parser {

	mutating func stmt() throws -> Expr {
		if match(symbols(["["])) != nil {
			try varDecl()
		} else if match(symbols([":"])) != nil {
			try typeDecl()
		} else {
			try expr()
		}
	}

	mutating func expr() throws -> Expr {
		try assign()
	}
	mutating func assign() throws -> Expr {
		try binary(
			expr: { try $0.term() },
			rhs: { try $0.assign() },
			map: ["=": Expr.assignment]
		)
	}
	mutating func term() throws -> Expr {
		try binary(expr: { try $0.factor() }, map: ["+": Expr.sum, "-": Expr.delta])
	}
	mutating func factor() throws -> Expr {
		try binary(expr: { try $0.composition() }, map: ["*": Expr.mul, "/": Expr.div])
	}
	mutating func composition() throws -> Expr {
		try binary(expr: { try $0.rcall() }, map: ["•": Expr.comp])
	}
	mutating func rcall() throws -> Expr {
		try binary(expr: { try $0.primary() }, map: ["#": Expr.rcall])
	}

	mutating func primary() throws -> Expr {
		if let int = match(\.int) {
			return .consti(int)
		}
		if let id = match(\.id) {
			return .id(id)
		}
		if let tks = match(\.tuple) {
			return try tuple(tks)
		}
		if match(symbols(["\\"])) != nil {
			return try lambda()
		}
		if let str = match(\.str) {
			return .consts(str)
		}
		throw err("Invalid primary \(tokens)")
	}

	func tuple(_ tokens: [Token]) throws -> Expr {
		try .tuple(tokens.split { $0.symbol == "," }.map { field in
			let fieldSplit = field.split { $0.symbol == ":" }

			if fieldSplit.count == 1 {
				var p = Parser(tokens: Array(field))
				return try ("", p.expr())
			} else if fieldSplit.count == 2, fieldSplit.first!.count == 1, case let .id(id) = fieldSplit.first!.first!.value {
				var p = Parser(tokens: Array(fieldSplit.last!))
				return try (id, p.expr())
			} else {
				throw err("Invalid tuple field \(Array(field))")
			}
		})
	}

	mutating func lambda() throws -> Expr {
		let labels = try labels()

		try consume(symbols([">"]), "`>` not found")

		if let tks = match(\.compound) {
			var p = Parser(tokens: tks)
			let stmts = try p.statements()
			return .funktion(0, labels, stmts)
		} else {
			let stmts = try [expr()]
			return .funktion(0, labels, stmts)
		}
	}

	mutating func varDecl() throws -> Expr {
		let id = try consume(\.id, "Expected identifier")
		try consume({ $0.symbol == ":" }, "Expected colon")
		let type = try typeExpr(collect { $0.symbol != "=" ? $0 : nil })

		try consume({ $0.symbol == "=" }, "Expected assignment")
		let expr = try expr()

		return .varDecl(id, type, expr)
	}

	mutating func typeDecl() throws -> Expr {
		let id = try consume(\.id, "Expected identifier")
		try consume({ $0.symbol == "=" }, "Expected assignment")
		let type = try typeExpr(collect { $0.symbol != ";" ? $0 : nil })

		return .typDecl(id, type)
	}

	mutating func labels() throws -> [String] {
		try .make { labels in
			if let id = match(\.id) {
				labels += [id]
				while match(symbols([","])) != nil {
					let next = try consume(\.id, "Label expected")
					labels += [next]
				}
			}
		}
	}

	mutating func statements() throws -> [Expr] {
		try .make { lst in
			lst += try [stmt()]
			while match(symbols([";"])) != nil {
				lst += try [stmt()]
			}
		}
	}

	func typeExpr(_ tokens: [Token]) throws -> TypeExpr {
		let fn = tokens.split { $0.value == .symbol(">") }

		if fn.count > 1 {
			let ts = try fn.map { ts in try typeExpr(Array(ts)) }
			let rs = ts.dropFirst().reduce(ts.first!) { r, e in .fn(r, e) }
			return rs
		} else if tokens.count == 1, case let .id(id) = tokens[0].value {
			return .id(id)
		} else if tokens.count == 2, let id = tokens[0].id, let cnt = tokens[1].int {
			return .arr(.id(id), Int(cnt))
		} else if tokens.count == 1, case let .tuple(tuple) = tokens[0].value {
			return try .tuple(tuple.split { $0.value == .symbol(",") }
				.map { ts in
					if ts.count > 2, case let .id(id) = ts[ts.startIndex].value, ts[ts.startIndex + 1].value == .symbol(":") {
						try (id, typeExpr(Array(ts.dropFirst(2))))
					} else {
						throw err("Invalid type expression \(ts.description)")
					}
				})
		} else {
			throw err("Invalid type expression \(tokens.description)")
		}
	}
}
