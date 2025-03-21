import Foundation

extension Scope {

	static var empty: Scope {
		Scope(
			parent: nil,
			types: ["int": .int, "float": .float, "char": .char, "bool": .bool, "void": .void],
			vars: [],
			exprs: []
		)
	}

	var locals: [Var] { [] }
	var statics: [Var] { [] }

	mutating func typeDecl(_ id: String, _ tokens: [Token]) throws {
		guard types[id] == nil else {
			throw CompilationError(description: "Redeclaration of \(id) on line: \(tokens.line)")
		}
		types[id] = try .type(id, typeExpr(tokens))
	}

	mutating func varDecl(_ type: Typ, _ id: String, _ tokens: [Token]) throws -> Var {
		if vars.first(where: { $0.name == id }) == nil {
			let v = Var(
				offset: vars.last.map { $0.offset + $0.type.size } ?? 0,
				type: type,
				name: id
			)
			vars.append(v)
			return v
		} else {
			throw CompilationError(description: "Redeclaration of var \(id) \(tokens.description)")
		}
	}

	func typeExpr(_ tokens: [Token]) throws -> Typ {
		let fn = tokens.split { $0.value == .symbol("<") }

		if fn.count > 1 {
			let ts = try fn.map { ts in try typeExpr(Array(ts)) }
			return ts.dropLast().reduce(ts.last!) { r, e in .function(e, r) }
		} else if tokens.count == 1, case let .id(id) = tokens[0].value {
			if let type = types[id] {
				return type
			} else {
				throw CompilationError(description: "Undeclared type \(id) \(tokens.description)")
			}
		} else if tokens.count == 2, case let .id(id) = tokens[0].value, case let .int(cnt) = tokens[1].value {
			if let type = types[id] {
				return .array(type, Int(cnt))
			} else {
				throw CompilationError(description: "Undeclared type \(id) \(tokens.description)")
			}
		} else if tokens.count == 1, case let .tuple(tuple) = tokens[0].value {
			return try .tuple(tuple.split { $0.value == .symbol(",") }
				.map { ts in
					if ts.count > 1, case let .id(id) = ts.last?.value {
						try VarDecl(type: typeExpr(ts.dropLast()), name: id)
					} else {
						throw CompilationError(description: "Invalid type expression \(ts.description)")
					}
				})
		} else {
			throw CompilationError(description: "Invalid type expression \(tokens.description)")
		}
	}

	func exprType(_ tokens: [Token]) throws -> Typ {
		if tokens.count == 1, case let .id(id) = tokens[0].value, let v = local(id) {
			return v.type
		} else {
			throw CompilationError(description: "Unknown expression type \(tokens.description)")
		}
	}

	func expr(_ type: Typ, _ tokens: [Token]) throws -> Expr {
		if tokens.count == 1 {
			switch (type, tokens[0].value) {
			case let (.int, .int(int)): return .consti(int)
			case let (.int, .hex(int)): return .constu(int)
			case let (type, .id(id)):
				if let v = local(id) {
//					if v.type == type
					return .variable(v)
				} else {
					throw CompilationError(description: "Undeclared var \(tokens[0].description)")
				}
			default:
				throw CompilationError(description: "Unknown expression \(tokens.description)")
			}
		} else {
			let sum = tokens.split(whereSeparator: { $0.value == .symbol("+") })

			if sum.count > 1 {
				return try sum.dropLast().reduce(expr(type, Array(sum.last!))) { r, e in
					try .sum(expr(type, Array(e)), r)
				}
			} else {
				throw CompilationError(description: "Unknown expression \(tokens.description)")
			}
		}
	}

	func local(_ id: String) -> Var? { vars.first(where: { $0.name == id }) }

	mutating func buildTree(tokens: [Token]) throws {
		let stmts = tokens.split { t in t.value == .symbol(";") }

		exprs = try stmts.compactMap { e in
			let assignment = e.split { t in t.value == .symbol("=") }
			let decl = e.split { t in t.value == .symbol(":") }

			if assignment.count == 1, decl.count == 1 {
				return try expr(.void, Array(e))
			} else if assignment.count == 1, decl.count == 2 {
				let lhs = decl[0]
				let rhs = decl[1]

				if lhs.count == 1, case let .id(id) = lhs.first?.value {
					try typeDecl(id, Array(rhs))
					return nil
				} else if lhs.count > 1, case let .id(id) = lhs.last?.value {
					let type = try typeExpr(lhs.dropLast())
					let v = try varDecl(type, id, Array(rhs))
					return try .assignment(.variable(v), expr(type, Array(rhs)))
				} else {
					throw CompilationError(description: "Invalid declaration \(Array(e).description)")
				}
			} else if assignment.count == 2, decl.count == 1 {
				let lhs = Array(assignment[0])
				let rhs = Array(assignment[1])
				let type = try exprType(lhs)
				return try .assignment(expr(type, lhs), expr(type, rhs))
			} else {
				throw CompilationError(
					description: "Only one declaration or assignment per statement is allowed"
				)
			}
		}
	}
}
