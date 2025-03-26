import Machine

public struct Program: Hashable {
	public var rawData: [Instruction]

	public init(rawData: [Instruction]) {
		self.rawData = rawData
	}
}

public extension Program {
	private nonisolated(unsafe) static var output = "" { didSet { stream(output) } }
	private nonisolated(unsafe) static var stream: (String) -> Void = { _ in }

	func run(_ stream: @escaping (String) -> Void) -> String {
		Self.stream = stream
		
		Self.output = "\nstack trace:"

		let len = Int32(rawData.count)
		Machine.loadProgram(rawData, len) { pc in
			Self.output = "\n\t\(pc / 4):\t" + readInstruction().description
		}

		let fn = Function(address: 3, closure: 0, aux: 0)
		let ret = Machine.runFunction(fn, 0)

		return ret == 0 ? "success: \(readRegister(0))" : "error: \(ret)"
	}
}
