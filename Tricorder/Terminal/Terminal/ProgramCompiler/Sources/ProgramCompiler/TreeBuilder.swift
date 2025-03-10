import Foundation

func buidTree(tokens: [Token]) throws -> [Stmt] {
	var types: [String: Typ] = .init(
		uniqueKeysWithValues: [.int, .float, .char, .void].map { ($0.name, $0) }
	)
	var vars: [String: Var] = [:]

	let stmts = tokens.split { t in t.value == .symbol(";") }

	let expr = { tokens in
		.consti(0)
	} as ([Token]) throws -> Expr

	return try stmts.map { stmt in
		let assignmentSplit = stmt.split { t in t.value == .symbol("=") }

		if assignmentSplit.count == 1 {
			return try .expr(expr(Array(stmt)))
		} else if assignmentSplit.count == 2 {
			return .decl(.int, "cnt", .consti(0))
		} else {
			throw TreeParsingError(
				description: "Only one assignment per statement is allowed"
			)
		}
	}
}

struct Var: Hashable {
	var type: Typ
	var name: String
}

extension Typ {
	static var int: Typ { Typ(name: "int", signature: "i") }
	static var float: Typ { Typ(name: "float", signature: "f") }
	static var char: Typ { Typ(name: "char", signature: "c") }
	static var void: Typ { Typ(name: "void", signature: "v") }
}
