import Foundation


//	func typeExpr(_ tokens: [Token]) throws -> Typ {
//		let fn = tokens.split { $0.value == .symbol("<") }
//
//		if fn.count > 1 {
//			let ts = try fn.map { ts in try typeExpr(Array(ts)) }
//			let rs = ts.dropFirst().reduce(ts.first!) { r, e in .function(r, e) }
//			return rs
//		} else if tokens.count == 1, case let .id(id) = tokens[0].value {
//			if let type = types[id] {
//				return type
//			} else {
//				throw err("Undeclared type \(id) \(tokens.description)")
//			}
//		} else if tokens.count == 2, case let .id(id) = tokens[0].value, case let .int(cnt) = tokens[1].value {
//			if let type = types[id] {
//				return .array(type, Int(cnt))
//			} else {
//				throw err("Undeclared type \(id) \(tokens.description)")
//			}
//		} else if tokens.count == 1, case let .tuple(tuple) = tokens[0].value {
//			return try .tuple(tuple.split { $0.value == .symbol(",") }
//				.map { ts in
//					if ts.count > 1, case let .id(id) = ts.last?.value {
//						try Field(type: typeExpr(ts.dropLast()), name: id)
//					} else {
//						throw err("Invalid type expression \(ts.description)")
//					}
//				})
//		} else {
//			throw err("Invalid type expression \(tokens.description)")
//		}
//	}
//
//	func exprType(_ tokens: [Token]) throws -> Typ {
//		if tokens.count == 1 {
//			if case let .id(id) = tokens[0].value, let v = local(id) {
//				return v.type
//			} else if case .int = tokens[0].value {
//				return .int
//			}
//		}
//		throw err("Unknown expression type \(tokens.description)")
//	}
//
//	func expr(_ type: Typ, _ tokens: [Token]) throws -> Expr {
//		var parser = Parser(tokens: tokens, scope: self)
//		return try parser.expr()
//	}

//	mutating func buildTree(tokens: [Token]) throws {

//		let stmts = tokens.split { t in t.value == .symbol(";") }
//
//		exprs = try stmts.enumerated().compactMap { i, e in
//			let isLast = i == stmts.count - 1
//			let assignment = e.split { t in t.value == .symbol("=") }
//			let decl = e.split { t in t.value == .symbol(":") }
//
//			if assignment.count == 1, decl.count == 1 {
//				return try expr(isLast ? output : .void, Array(e))
//			} else if assignment.count == 1, decl.count == 2 {
//				let lhs = decl[0]
//				let rhs = decl[1]
//
//				if lhs.count == 1, case let .id(id) = lhs.first?.value {
//					try typeDecl(id, Array(rhs))
//					return nil
//				} else if lhs.count > 1, case let .id(id) = lhs.last?.value {
//					let type = try typeExpr(lhs.dropLast())
//					_ = try varDecl(type, id, Array(rhs))
//					return try .assignment(.id(id), expr(type, Array(rhs)))
//				} else {
//					throw err("Invalid declaration \(Array(e).description)")
//				}
//			} else if assignment.count == 2, decl.count == 1 {
//				let lhs = Array(assignment[0])
//				let rhs = Array(assignment[1])
//				let type = try exprType(lhs)
//				return try .assignment(expr(type, lhs), expr(type, rhs))
//			} else {
//				throw CompilationError(
//					description: "Only one declaration or assignment per statement is allowed"
//				)
//			}
//		}
//	}
//}
