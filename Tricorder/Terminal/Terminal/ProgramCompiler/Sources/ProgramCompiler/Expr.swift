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

	mutating func traverse(leavesFirst: Bool = false, _ transform: (inout Expr, Scope) -> Bool) {
		for idx in exprs.indices { exprs[idx].traverse(in: self, leavesFirst: leavesFirst, transform: transform) }
	}
	mutating func traverseAll(_ transform: (inout Expr, Scope) -> Void) {
		traverse { e, s in transform(&e, s); return false }
	}
	mutating func traverseLeavesFirst(_ transform: (inout Expr, Scope) -> Void) {
		traverse(leavesFirst: true) { e, s in transform(&e, s); return false }
	}
	mutating func traverseExprs(_ transform: (inout Expr, Scope) -> Void) {
		traverse { e, s in
			transform(&e, s)
			return if case .funktion = e { true } else { false }
		}
	}
}

extension Expr {

	mutating func traverse(in scope: Scope, leavesFirst: Bool = false, transform: (inout Expr, Scope) -> Bool) {
		if !leavesFirst, transform(&self, scope) { return }

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl:
			break
		case .varDecl(let id, let type, var e):
			e.traverse(in: scope, transform: transform)
			self = .varDecl(id, type, e)
		case .funktion(let id, let labels, var scope):
			scope.traverse(transform)
			self = .funktion(id, labels, scope)
		case .binary(let op, var lhs, var rhs):
			lhs.traverse(in: scope, transform: transform)
			rhs.traverse(in: scope, transform: transform)
			self = .binary(op, lhs, rhs)
		}

		if leavesFirst { _ = transform(&self, scope) }
	}
}
