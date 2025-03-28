import ProgramCompiler
import Foundation
import AppKit

extension String {

	func highlighted(tokens: [Token]) -> Attributes {
		tokens.reduce(into: [:]) { r, e in
			var attrs = r[e.range] ?? [:]
			let subtokens = e.subtokens
			if subtokens.isEmpty {
				attrs[.foregroundColor] = e.color
				r[e.range] = attrs
			} else {
				r = subtokens.reduce(into: r) { r, e in
					var attrs = r[e.range] ?? [:]
					attrs[.foregroundColor] = e.color
					r[e.range] = attrs
				}
			}
		}
	}
}

private extension Token {

	var color: NSColor {
		switch value {
		case .string: .txt5
		case .int, .hex, .float: .txt2
		case .symbol("#"): .txt4
		case .symbol: .txt6
		case .id: .txt0
		case .comment: .txt3
		case .compound, .tuple: .txt0
		}
	}

	var subtokens: [Token] {
		switch value {
		case .compound(let tks): tks
		case .tuple(let tks): tks
		default: []
		}
	}
}

extension NSColor {

	static var txt0: NSColor { .init(light: NSColor(0x1B1918), dark: NSColor(0xFEEFEE)) }
	static var txt1: NSColor { .init(light: NSColor(0x2C2421), dark: NSColor(0xE6E2E0)) }
	static var txt2: NSColor { .init(light: NSColor(0x68615E), dark: NSColor(0xA8A19F)) }
	static var txt3: NSColor { .init(light: NSColor(0x766E6B), dark: NSColor(0x9C9491)) }

	static var txt4: NSColor { .init(light: NSColor(0xDF5320), dark: NSColor(0xDF5320)) }
	static var txt5: NSColor { .init(light: NSColor(0xC38418), dark: NSColor(0xC38418)) }
	static var txt6: NSColor { .init(light: NSColor(0x7B9726), dark: NSColor(0x7B9726)) }
	static var txt7: NSColor { .init(light: NSColor(0x00AD9C), dark: NSColor(0x00AD9C)) }

	convenience init(_ value: RGBA32) {
		self.init(
			red: CGFloat(value.red) / 255,
			green: CGFloat(value.green) / 255,
			blue: CGFloat(value.blue) / 255,
			alpha: CGFloat(value.alpha) / 255
		)
	}

	convenience init(light: NSColor, dark: NSColor) {
		self.init(name: nil) { appearance in
			appearance.name == .aqua ? light : dark
		}
	}
}

struct RGBA32: Hashable, Codable {
	var red: UInt8
	var green: UInt8
	var blue: UInt8
	var alpha: UInt8
}

extension RGBA32: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self = RGBA32(hex: value)
	}
}

extension RGBA32 {

	init(hex value: Int) {
		self = RGBA32(
			red: value[byte: 2],
			green: value[byte: 1],
			blue: value[byte: 0],
			alpha: .max
		)
	}

	var hex: Int { Int(red) << 16 | Int(green) << 8 | Int(blue) }
	var hexString: String { String(format: "%06X", hex) }
}

extension Int {
	subscript(byte byte: Int) -> UInt8 {
		let bits = byte * 8
		let mask = 0xFF << bits
		let shifted = (self & mask) >> bits
		return UInt8(shifted)
	}
}


struct HSBA {
	var hue: CGFloat
	var saturation: CGFloat
	var brightness: CGFloat
	var alpha: CGFloat
}

extension NSColor {

	var hsba: HSBA {
		var hsba = HSBA(hue: 0, saturation: 0, brightness: 0, alpha: 0)
		getHue(&hsba.hue, saturation: &hsba.saturation, brightness: &hsba.brightness, alpha: &hsba.alpha)
		return hsba
	}

	convenience init(hsba: HSBA) {
		self.init(hue: hsba.hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
	}
}
