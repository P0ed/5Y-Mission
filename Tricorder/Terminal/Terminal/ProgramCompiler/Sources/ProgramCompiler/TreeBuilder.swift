import Foundation

func buidTree(tokens: [Token]) throws -> Scope {
	var types: [String: Typ] = .init(
		uniqueKeysWithValues: [.int, .float, .char, .void].map { ($0.name, $0) }
	)
	var vars: [String: Var] = [:]

	let stmts = tokens.split { t in t.value == .symbol(";") }

	func typeDecl(_ id: String, _ tokens: [Token]) throws -> TypDecl {
		guard types[id] == nil else {
			throw CompilationError(description: "Redeclaration of \(id) on line: \(tokens.line)")
		}
		let expr = try typeExpr(tokens)
		types[id] = Typ(name: id, layout: expr.layout)

		return TypDecl(name: id, value: expr)
	}

	func varDecl(_ type: TypExpr, _ id: String, _ tokens: [Token]) throws -> VarDecl {
		switch type {
		case let .type(type):
			let expr = try expr(tokens)
			vars[id] = Var(type: type, name: id)
			return VarDecl(type: type, name: id, value: expr)
		case let .array(.type(type), _):
			let expr = try expr(tokens)
			vars[id] = Var(type: type, name: id)
			return VarDecl(type: type, name: id, value: expr)
		default:
			throw CompilationError(description: "Invalid declaration \(tokens.description)")
		}
	}

	func typeExpr(_ tokens: [Token]) throws -> TypExpr {
		if tokens.count == 1, case let .id(id) = tokens[0].value {
			if let type = types[id] {
				return .type(type)
			} else {
				throw CompilationError(description: "Undeclared type \(id) \(tokens.description)")
			}
		} else {
			throw CompilationError(description: "Invalid type expression \(tokens.description)")
		}
	}

	func expr(_ tokens: [Token]) throws -> Expr {
		.consti(0)
	}

	return try Scope(
		types: types,
		vars: vars,
		statements: stmts.map { stmt in
			let assignment = stmt.split { t in t.value == .symbol("=") }
			let decl = stmt.split { t in t.value == .symbol(":") }

			if assignment.count == 1, decl.count == 1 {
				return try .expr(expr(Array(stmt)))
			} else if assignment.count == 1, decl.count == 2 {
				let lhs = decl[0]
				let rhs = decl[1]

				if lhs.count == 1, case let .id(id) = lhs.first?.value {
					return try .typeDecl(typeDecl(id, Array(decl[1])))
				} else if lhs.count > 1, case let .id(id) = lhs.last?.value {
					let type = try typeExpr(lhs.dropLast())
					return try .varDecl(varDecl(type, id, Array(rhs)))
				} else {
					throw CompilationError(description: "Invalid declaration \(Array(stmt).description)")
				}
			} else if assignment.count == 2, decl.count == 1 {
				return try .assignment(expr(Array(assignment[0])), expr(Array(assignment[1])))
			} else {
				throw CompilationError(
					description: "Only one \(decl.count > 1 ? "declaration" : "assignment") per statement is allowed"
				)
			}
		}
	)
}

struct Var: Hashable {
	var type: Typ
	var name: String
}

extension Typ {
	static var int: Typ { Typ(name: "int", layout: "i") }
	static var float: Typ { Typ(name: "float", layout: "f") }
	static var char: Typ { Typ(name: "char", layout: "c") }
	static var void: Typ { Typ(name: "void", layout: "") }
}
