import Foundation

public func compile(program: String) throws -> Data {
	Data()
}

indirect enum Expr<T> {
	case lhs(Expr)
	case rhs(Expr)
	case const(Int32)
	case constf(Float)
	case consts(String)
}
