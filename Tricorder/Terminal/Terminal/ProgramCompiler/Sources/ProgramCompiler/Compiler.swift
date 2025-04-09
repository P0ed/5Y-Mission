import Machine

func err(_ msg: String) -> CompilationError { .init(description: msg) }

public extension Scope {

	init(tokens: [Token]) throws {
		self = .init()
		var p = Parser(tokens: tokens)
		exprs = try p.statements()
		try precompile()
	}

	init(program: String) throws {
		self = try .init(tokens: program.tokenized().filter {
			if case .comment = $0.value { false } else { true }
		})
	}

	func compile() throws -> Program {
		let compiledFuncs = funcs.map(\.program.instructions).reduce(into: [], +=)
		var instructions = compiledFuncs

		let exprsCount = exprs.count
		for (idx, expr) in exprs.enumerated() {
			var isLast: Bool { idx == exprsCount - 1 }

			switch expr {
			case let .varDecl(name, _, rhs):
				let v = try local(name).unwraped("Unknown id \(name)")
				instructions += try eval(ret: u8(v.offset), expr: rhs, type: v.type)
			case let .binary(.assign, .id(id), rhs):
				let v = try local(id).unwraped("Unknown id \(id)")
				instructions += try eval(ret: u8(v.offset), expr: rhs, type: v.type)
			default:
				instructions += try eval(
					ret: isLast ? 0 : temporary,
					expr: expr,
					type: isLast ? output : .void
				)
			}
		}

		if parent() != nil {
			instructions += vars.reduce(into: []) { r, v in
				if case .function = v.type {
					r += [CLRL(x: v.register.offset)]
				}
			}
		}

		instructions += [RET()]

		if parent() == nil {
			guard instructions.count < u16.max else { throw err("Instructions count > UInt16.max") }
			instructions.append(FN(x: 0, yz: u16(compiledFuncs.count)))
		}

		return Program(instructions: instructions)
	}

	func loadInt(rx: u8, value: Int32) -> [Instruction] {
		[
			RXI(x: rx, yz: u16(value & 0xFFFF))
		] + (value > 0xFFFF ? [
			RXU(x: rx, yz: u16(value >> 16))
		] : [])
	}

	func integer(op: OPCode, const: (Int32, Int32) -> Int32, ret: u8, type: Typ, lhs: Expr, rhs: Expr) throws -> [Instruction] {
		switch (lhs, rhs) {
		case let (.consti(l), .consti(r)):
			return loadInt(rx: ret, value: const(l, r))
		case let (.id(id), .consti(c)):
			let v = try local(id).unwraped("Unknown id \(id)")
			guard v.type.resolved == .int else {
				throw err("Type mismatch \(v.type) != .int")
			}

			return loadInt(rx: temporary, value: c) + [
				op(x: ret, y: v.register, z: temporary)
			]
		case let (.consti(c), .id(id)):
			let v = try local(id).unwraped("Unknown id \(id)")
			guard v.type.resolved == .int else { throw err("Type mismatch \(v.type) != .int") }

			return loadInt(rx: temporary, value: c) + [
				op(x: ret, y: temporary, z: v.register)
			]
		case let (.id(lhs), .id(rhs)):
			let l = try local(lhs).unwraped("Unknown id \(lhs)")
			let r = try local(rhs).unwraped("Unknown id \(rhs)")
			guard l.type.resolved == r.type.resolved else { throw err("Type mismatch \(l.type) != \(r.type)") }

			return [
				op(x: ret, y: l.register, z: r.register)
			]
		case let (expr, .id(id)), let (.id(id), expr):
			let r = try local(id).unwraped("Unknown id \(id)")

			return try eval(ret: ret, expr: expr, type: .int) + [
				op(x: ret, y: ret, z: r.register)
			]
		case let (expr, .consti(c)), let (.consti(c), expr):
			return try eval(ret: ret, expr: expr, type: .int) + loadInt(rx: temporary, value: c) + [
				op(x: ret, y: ret, z: temporary)
			]
		default: throw err("Invalid \(op) operation")
		}
	}

	func add(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		try integer(op: ADD, const: +, ret: ret, type: type, lhs: lhs, rhs: rhs)
	}
	func sub(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		try integer(op: SUB, const: -, ret: ret, type: type, lhs: lhs, rhs: rhs)
	}
	func mul(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		try integer(op: MUL, const: *, ret: ret, type: type, lhs: lhs, rhs: rhs)
	}
	func div(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		try integer(op: DIV, const: /, ret: ret, type: type, lhs: lhs, rhs: rhs)
	}

	func rcall(_ ret: u8, _ type: Typ, _ lhs: Expr, _ rhs: Expr) throws -> [Instruction] {
		if case let .id(v) = lhs {
			if let fn = local(v) {
				if case let .function(arrow) = fn.type, arrow.o == type {
					return try eval(ret: temporary + u8(type.size), expr: rhs, type: arrow.i) + [
						FNRX(x: temporary, y: fn.register),
						RXRX(x: ret, y: temporary)
					]
				} else {
					throw err("Type mismatch")
				}
			} else if v == "print" {
				return try eval(ret: temporary, expr: rhs, type: .array(.char, 24)) + [
					PRNT(x: temporary)
				]
			} else {
				throw err("Unknown id")
			}
		} else {
			throw err("Invalid function expression")
		}
	}

	private func eval(ret: u8, expr: Expr, type: Typ) throws -> [Instruction] {
		var instructions = [] as [Instruction]

		switch expr {
		case let .consti(int):
			instructions += loadInt(rx: ret, value: int)
		case let .consts(s):
			let encoded = s.filter(\.isASCII).cString(using: .ascii) ?? []
			let itemAt: (Int) -> u8 = {
				$0 < encoded.count ? encoded[$0].magnitude : 0
			}

			if type.resolved == .char, encoded.count == 2 {
				return [RXI(x: ret, yz: u16(itemAt(0)))]
			}

			guard case let .array(.char, cnt) = type.resolved, encoded.count < cnt else {
				throw err("Can't fit \"\(s)\" into \(type)")
			}
			instructions += (0..<((encoded.count + 3) / 4)).flatMap { idx in
				let i: u16 = u16(itemAt(idx * 4 + 0)) | u16(itemAt(idx * 4 + 1)) << 8
				let u: u16 = u16(itemAt(idx * 4 + 2)) | u16(itemAt(idx * 4 + 3)) << 8
				return [RXI(x: ret + u8(idx), yz: i), RXU(x: ret + u8(idx), yz: u)]
			}
		case let .id(id):
			let v = try local(id).unwraped("Unknown id \(id)")

			for i in u8.min..<u8(v.type.size) {
				instructions += [RXRX(x: ret + i, y: v.register + i)]
			}
		case let .binary(.rcall, lhs, rhs):
			instructions += try rcall(ret, type, lhs, rhs)
		case let .binary(.sum, lhs, rhs):
			instructions += try add(ret, type, lhs, rhs)
		case let .binary(.sub, lhs, rhs):
			instructions += try sub(ret, type, lhs, rhs)
		case let .binary(.mul, lhs, rhs):
			instructions += try mul(ret, type, lhs, rhs)
		case let .binary(.div, lhs, rhs):
			instructions += try div(ret, type, lhs, rhs)
		case let .funktion(fid, _, fs):
			let fn = try funcs.first { $0.id == fid }.unwraped("Unknown func \(fid)")
			if fs.closure.isEmpty {
				instructions += [RXI(x: ret, yz: u16(fn.offset))]
			} else {
				instructions += [CLMK(x: ret, yz: u16(fn.offset))]

				for c in fs.closure {
					let origin = try local(c.name).unwraped("Var \(c.name) not found")
					for i in u8.min..<u8(c.type.size) {
						instructions += [RXRX(
							x: .init(selector: .aux, offset: c.register.offset + i),
							y: origin.register + i,
							z: 0
						)]
					}
				}
			}
		case let .tuple(fs):
			if case let .tuple(fields) = type.resolved, fields.count == fs.count {
				var df = 0 as u8
				instructions += try zip(fields, fs).reduce(into: []) { r, e in
					r += try eval(ret: ret + df, expr: e.1.1, type: e.0.type)
					df += u8(e.0.type.size)
				}
			} else if case let .array(t, cnt) = type.resolved, fs.count == cnt {
				var df = 0 as u8
				instructions += try fs.reduce(into: []) { r, e in
					r += try eval(ret: ret + df, expr: e.1, type: t)
					df += u8(t.size)
				}
			} else {
				throw err("Invalid tuple \(fs)")
			}
		case .binary(.comp, _, _): throw err("Function composition not implemented yet")
		case .typDecl: break
		default: throw err("Invalid expression \(expr)")
		}
		return instructions
	}
}

extension OPCode {
	func callAsFunction(x: u8 = 0, yz: u16 = 0) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(yz: i16(u: yz)))
	}
	func callAsFunction(x: u8, y: u8, z: u8 = 0) -> Instruction {
		Instruction(op: self, x: i8(u: x), .init(.init(y: i8(u: y), z: i8(u: z))))
	}
}

extension u8 {
	init(selector: u8, offset: u8) {
		self = selector << 6 | offset & 0x3F
	}
	var selector: u8 { self >> 6 }
	var offset: u8 { self & 0x3F }

	static var top: u8 { 0b00 }
	static var closure: u8 { 0b01 }
	static var aux: u8 { 0b10 }
	static var bottom: u8 { 0b11 }
}
