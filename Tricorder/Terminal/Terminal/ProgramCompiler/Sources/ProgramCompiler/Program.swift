import Machine

public struct Program: Hashable {
	public var rawData: [Instruction]

	public init(rawData: [Instruction]) {
		self.rawData = rawData
	}
}

public extension Program {
	private nonisolated(unsafe) static var streamTrampoline: String { get { "" } set { stream(newValue) } }
	private nonisolated(unsafe) static var stream: (String) -> Void = { _ in }

	func run(_ stream: @escaping (String) -> Void) -> Int {
		Self.stream = stream

		stream("\nprogram started:\n")

		let ret = Machine.runProgram(rawData, u16(rawData.count)) { pc, inn in
			Self.streamTrampoline = "\t\(Self.instructionDescription(idx: Int(pc), inn: inn))\n"
		}

		let registers = (UInt8.min..<(ret == 0 ? 4 : 0)).reduce(into: "") { r, i in
			r += "\n\trx[\(i)] = \(readRegister(i))"
		}
		stream("\nexit: \(ret)\(registers)\n")

		return Int(ret)
	}
}
