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
		 call(Expr, Expr),
		 sum(Expr, Expr),
		 delta(Expr, Expr),
		 mul(Expr, Expr),
		 div(Expr, Expr)
}

public indirect enum TypeExpr {
	case id(String),
		 arr(TypeExpr, Int),
		 fn(TypeExpr, TypeExpr),
		 ptr(TypeExpr),
		 tuple([(String, TypeExpr)])
}
