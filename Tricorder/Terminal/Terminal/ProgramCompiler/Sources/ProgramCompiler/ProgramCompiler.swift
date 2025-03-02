import Foundation

public func compile(program: String) throws -> Data {
	try Expr(program: program).compile()
}

indirect enum Expr {
	case lhs(Expr)
	case rhs(Expr)
	case const(Int32)
	case constf(Float)
	case consts(String)
}

struct TreeParsingError: Error {
	var description: String
}

struct CompilationError: Error {
	var description: String
}

extension Expr {

	init(program: String) throws {
		self = .const(0)

		throw TreeParsingError(description: "Failed to parse program:\n\(program)")
	}
}

extension Expr {

	func compile() throws -> Data {
		throw CompilationError(description: "Failed to compile tree: \(self)")
	}
}
