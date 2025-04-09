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
}

extension Expr {

	mutating func traverse(in scope: Scope, _ transform: (inout Expr, Scope) -> Void) {
		transform(&self, scope)

		switch self {
		case .consti, .constu, .constf, .consts, .id, .tuple, .typDecl:
			break
		case .varDecl(let id, let type, var e):
			transform(&e, scope)
			self = .varDecl(id, type, e)
		case .funktion(let id, let labels, var scope):
			scope.traverse(transform)
			self = .funktion(id, labels, scope)
		case .binary(let op, var lhs, var rhs):
			transform(&lhs, scope)
			transform(&rhs, scope)
			self = .binary(op, lhs, rhs)
		}
	}
	
	/// Finds all references to variables that exist in the parent scope but not in the current scope
	func findReferencesTo(inParent parentScope: Scope, ofScope currentScope: Scope, addingTo capturedVars: inout [Var]) {
		switch self {
		case let .id(name):
			// If variable isn't in current scope but exists in parent scope, it needs to be captured
			if currentScope.local(name) == nil, let v = parentScope.local(name) {
				// Only add if not already in capture list
				if !capturedVars.contains(where: { $0.name == name }) {
					let offset = capturedVars.map(\.type.size).reduce(0, +)
					capturedVars.append(Var(offset: offset, type: v.type, name: name))
				}
			}
		case .consti, .constu, .constf, .consts, .typDecl:
			break
		case let .varDecl(_, _, expr):
			expr.findReferencesTo(inParent: parentScope, ofScope: currentScope, addingTo: &capturedVars)
		case .funktion:
			// Skip nested functions as they will be handled separately
			break
		case let .binary(_, lhs, rhs):
			lhs.findReferencesTo(inParent: parentScope, ofScope: currentScope, addingTo: &capturedVars)
			rhs.findReferencesTo(inParent: parentScope, ofScope: currentScope, addingTo: &capturedVars)
		case let .tuple(fields):
			for (_, expr) in fields {
				expr.findReferencesTo(inParent: parentScope, ofScope: currentScope, addingTo: &capturedVars)
			}
		}
	}
}
