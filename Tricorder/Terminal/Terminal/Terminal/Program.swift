import Machine
import ProgramCompiler

extension Program {

	private nonisolated(unsafe) static var breakpointTrampoline: (u16, Instruction) {
		get { (0, .init(op: .init(0), x: .init(u: 0), .init(yz: .init(u: 0)))) }
		set { halt = breakpoint(newValue.0, newValue.1) }
	}
	private nonisolated(unsafe) static var halt: s32 = 0
	private nonisolated(unsafe) static var printTrampoline: String {
		get { "" } set { print(newValue) }
	}
	private nonisolated(unsafe) static var breakpoint: (u16, Instruction) -> s32 = { _, _ in 0 }
	private nonisolated(unsafe) static var print: (String) -> Void = { _ in }

	func run(scope: Scope, breakpoint: @escaping (u16, Instruction) -> s32, print: @escaping (String) -> Void) -> Int {
		Self.breakpoint = breakpoint
		Self.print = print

		print("\nprogram started:\n")

		let ret = Machine.runProgram(
			instructions, u16(instructions.count),
			{ pc, inn in
				Self.breakpointTrampoline = (pc, inn)
				if inn.op == BREK {
					
				}
				return Self.halt
			},
			{ cString in
				Self.printTrampoline = cString.map { String(cString: $0) + "\n" } ?? ""
			}
		)

		if ret == 0 {
			let vars = scope.vars.reversed()

			let rx: (Int) -> String = { i in
				let v = vars.first { $0.offset <= i }
				let name = v.map { $0.name + (($0.type.size > 1) ? "[\(i - $0.offset)]" : "") } ?? ""

				return "Rx\(u8(i).hex)\t\(name)"
			}

			let registers = (u8.min..<u8(scope.size)).reduce(into: "") { r, i in
				let v = vars.first { $0.offset <= i }
				let value = readRegister(0, i)

				if let v, case .function = v.type {
					r += "\n\t\(rx(Int(i))) = \(value & 0xFFFF)<\(value >> 24)>"
				} else {
					r += "\n\t\(rx(Int(i))) = \(value)"
				}
			}
			print("\nexit: \(ret)\(registers)\n")
		}

		return Int(ret)
	}
}
