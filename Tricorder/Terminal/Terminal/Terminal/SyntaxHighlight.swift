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
				r.merge(highlighted(tokens: subtokens)) { l, r in r }
			}
		}
	}
}

private extension Token {

	var color: NSColor {
		switch value {
		case .string: .txt5
		case .int, .hex, .float: .txt2
		case .symbol("#"), .symbol("•"): .txt4
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
