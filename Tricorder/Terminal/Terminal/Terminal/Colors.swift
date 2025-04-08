import SwiftUI
import AppKit

extension Color {
	static var editorLight: Color { .init(white: 1) }
	static var editorDark: Color { .init(white: 0.1) }

	static var consoleLight: Color { .init(white: 0.96) }
	static var consoleDark: Color { .init(white: 0.13) }

	static var overlayLight: Color { .init(white: 0.98, opacity: 0.88) }
	static var overlayDark: Color { .init(white: 0.14, opacity: 0.92) }

	static var amberLight: Color { .init(red: 0.8, green: 0.7, blue: 0.2, opacity: 0.2) }
	static var amberDark: Color { .init(red: 0.8, green: 0.7, blue: 0.1, opacity: 0.3) }
}

extension ColorScheme {
	var editorColor: Color { self == .light ? .editorLight : .editorDark }
	var consoleColor: Color { self == .light ? .consoleLight : .consoleDark }
	var overlayColor: Color { self == .light ? .overlayLight : .overlayDark }
	var tintColor: Color { self == .light ? .amberLight : .amberDark }
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
	public init(integerLiteral value: Int) { self = RGBA32(hex: value) }
}

extension RGBA32 {
	init(hex: Int) {
		self = RGBA32(red: hex[byte: 2], green: hex[byte: 1], blue: hex[byte: 0], alpha: .max)
	}
	var hex: Int { Int(red) << 16 | Int(green) << 8 | Int(blue) }
}

private extension Int {
	subscript(byte byte: Int) -> UInt8 {
		let bits = byte * 8
		let mask = 0xFF << bits
		let shifted = (self & mask) >> bits
		return UInt8(shifted)
	}
}
