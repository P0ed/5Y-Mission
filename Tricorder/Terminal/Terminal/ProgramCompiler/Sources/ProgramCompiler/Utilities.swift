extension Optional {
	var array: [Wrapped] { map { [$0] } ?? [] }

	func unwraped(_ error: @autoclosure () -> String) throws -> Wrapped {
		if let wrapped = self { return wrapped }
		throw CompilationError(description: error())
	}
}

extension Array {

	static func make(_ f: (inout Array) throws -> Void) rethrows -> Array {
		var acc = Array()
		try f(&acc)
		return acc
	}
}
