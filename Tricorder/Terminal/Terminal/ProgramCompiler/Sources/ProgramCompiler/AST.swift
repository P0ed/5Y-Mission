public indirect enum Expr {
	case consti(Int32),
		 constu(UInt32),
		 constf(Float),
		 consts(String),
		 id(String),
		 tuple([(String, Expr)]),
		 typDecl(String, TypeExpr),
		 varDecl(String, TypeExpr, Expr),
		 funktion(Int, [String], [Expr]),
		 assignment(Expr, Expr),
		 rcall(Expr, Expr),
		 sum(Expr, Expr),
		 delta(Expr, Expr),
		 mul(Expr, Expr),
		 div(Expr, Expr),
		 comp(Expr, Expr)
}

public indirect enum TypeExpr {
	case id(String),
		 arr(TypeExpr, Int),
		 fn(TypeExpr, TypeExpr),
		 ptr(TypeExpr),
		 tuple([(String, TypeExpr)])
}

extension [Expr] {

	mutating func mutate(_ mut: (inout Expr) -> Void) {
		for idx in indices { self[idx].mutate(mut) }
	}
}

extension Expr {

	mutating func mutate(_ mut: (inout Expr) -> Void) {
		mut(&self)

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl:
			break
		case .varDecl(let id, let type, var e):
			mut(&e)
			self = .varDecl(id, type, e)
		case .funktion(let id, let labels, var exprs):
			exprs.mutate(mut)
			self = .funktion(id, labels, exprs)
		case var .assignment(l, r):
			mut(&l)
			mut(&r)
			self = .assignment(l, r)
		case var .rcall(l, r):
			mut(&l)
			mut(&r)
			self = .rcall(l, r)
		case var .sum(l, r):
			mut(&l)
			mut(&r)
			self = .sum(l, r)
		case var .delta(l, r):
			mut(&l)
			mut(&r)
			self = .delta(l, r)
		case var .mul(l, r):
			mut(&l)
			mut(&r)
			self = .mul(l, r)
		case var .div(l, r):
			mut(&l)
			mut(&r)
			self = .div(l, r)
		case var .comp(l, r):
			mut(&l)
			mut(&r)
			self = .comp(l, r)
		}
	}
}
