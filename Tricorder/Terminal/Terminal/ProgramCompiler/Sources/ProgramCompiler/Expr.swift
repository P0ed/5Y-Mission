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
	// Assignment
	case assign
	// Function composition and application
	case rcall, comp
	// Arithmetic
	case sum, sub, mul, div, mod
	// Logical
	case or, and, not
	// Comparison
	case eq, neq, gt, gte, lt, lte
	// Control flow
	case ctrl
	// Unary
	case deref, ref, neg
	// Postfix
	case call, dot, index
}

public indirect enum TypeExpr {
	case id(String),
		 arr(TypeExpr, Int),
		 fn(TypeExpr, TypeExpr),
		 ptr(TypeExpr),
		 tuple([(String, TypeExpr)])
}

extension Scope {

	func traverse(leavesFirst: Bool = false, _ transform: (inout Expr, Scope) throws -> Bool) rethrows {
		for idx in exprs.indices {
			try exprs[idx].traverse(in: self, leavesFirst: leavesFirst, transform: transform)
		}
	}
	func traverseAll(_ transform: (inout Expr, Scope) throws -> Void) rethrows {
		try traverse { e, s in try transform(&e, s); return false }
	}
	func traverseLeavesFirst(_ transform: (inout Expr, Scope) throws -> Void) rethrows {
		try traverse(leavesFirst: true) { e, s in try transform(&e, s); return false }
	}
	func traverseExprs(_ transform: (inout Expr, Scope) throws -> Void) rethrows {
		try traverse { e, s in
			try transform(&e, s)
			return if case .funktion = e { true } else { false }
		}
	}
}

extension Expr {

	mutating func traverse(in scope: Scope, leavesFirst: Bool = false, transform: (inout Expr, Scope) throws -> Bool) rethrows {
		if !leavesFirst, try transform(&self, scope) { return }

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl:
			break
		case .varDecl(let id, let type, var e):
			try e.traverse(in: scope, transform: transform)
			self = .varDecl(id, type, e)
		case let .funktion(id, labels, scope):
			try scope.traverse(transform)
			self = .funktion(id, labels, scope)
		case .binary(let op, var lhs, var rhs):
			try lhs.traverse(in: scope, transform: transform)
			try rhs.traverse(in: scope, transform: transform)
			self = .binary(op, lhs, rhs)
		}

		if leavesFirst { _ = try transform(&self, scope) }
	}
}
