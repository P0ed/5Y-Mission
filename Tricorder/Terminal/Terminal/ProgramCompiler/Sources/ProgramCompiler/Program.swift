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

	func run(_ meta: Scope?, _ stream: @escaping (String) -> Void) -> Int {
		Self.stream = stream

		stream("\nprogram started:\n")

		let ret = Machine.runProgram(
			rawData, u16(rawData.count),
			{ pc, inn in Self.streamTrampoline = "\t\(Self.instructionDescription(idx: Int(pc), inn: inn))\n" },
			{ cString in Self.streamTrampoline = cString.map(String.init(cString:)) ?? "" }
		)

		let rx: (Int) -> String = { i in
			let v = (meta?.vars ?? []).reversed().first { $0.offset <= i }
			let name: String? = v.map { $0.name + (($0.type.size > 1) ? "[\(i - $0.offset)]" : "") }

			return name ?? "rx[\(i)]"
		}
		let registers = (u8.min..<(ret == 0 ? u8(meta?.size ?? 4) : 0)).reduce(into: "") { r, i in
			r += "\n\t\(rx(Int(i))) = \(readRegister(i))"
		}
		stream("\nexit: \(ret)\(registers)\n")

		return Int(ret)
	}
}
