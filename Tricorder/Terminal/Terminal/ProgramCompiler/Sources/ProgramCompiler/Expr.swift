public indirect enum Expr {
	case consti(Int32),
		 constu(UInt32),
		 constf(Float),
		 consts(String),
		 id(String),
		 tuple([(String, Expr)]),
		 typDecl(String, TypeExpr),
		 varDecl(String, TypeExpr, Expr),
		 funktion(Int, [String], Scope),
		 binary(Operator, Expr, Expr)
}

public enum Operator {
	case assign, rcall, sum, sub, mul, div, mod, comp
}

public indirect enum TypeExpr {
	case id(String),
		 arr(TypeExpr, Int),
		 fn(TypeExpr, TypeExpr),
		 ptr(TypeExpr),
		 tuple([(String, TypeExpr)])
}

extension Scope {

	mutating func traverse(_ transform: (inout Expr, Scope) -> Void) {
		for idx in exprs.indices { exprs[idx].traverse(in: self, transform) }
	}
	mutating func traverseExprs(_ transform: (inout Expr, Scope) -> Void) {
		for idx in exprs.indices { exprs[idx].traverseExprs(in: self, transform) }
	}
}

extension Expr {

	mutating func traverse(in scope: Scope, _ transform: (inout Expr, Scope) -> Void) {
		transform(&self, scope)

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl:
			break
		case .varDecl(let id, let type, var e):
			e.traverse(in: scope, transform)
			self = .varDecl(id, type, e)
		case .funktion(let id, let labels, var scope):
			scope.traverse(transform)
			self = .funktion(id, labels, scope)
		case .binary(let op, var lhs, var rhs):
			lhs.traverse(in: scope, transform)
			rhs.traverse(in: scope, transform)
			self = .binary(op, lhs, rhs)
		}
	}

	mutating func traverseExprs(in scope: Scope, _ transform: (inout Expr, Scope) -> Void) {
		transform(&self, scope)

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl, .funktion:
			break
		case .varDecl(let id, let type, var e):
			transform(&e, scope)
			self = .varDecl(id, type, e)
		case .binary(let op, var lhs, var rhs):
			transform(&lhs, scope)
			transform(&rhs, scope)
			self = .binary(op, lhs, rhs)
		}
	}
}
