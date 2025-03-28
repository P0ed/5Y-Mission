import SwiftUI
import AppKit

struct TextEditor: NSViewRepresentable {
	@Binding var text: String
	@Binding var attributes: Attributes?

	func makeNSView(context: Context) -> NSTextView {
		let view = NSTextView()
		view.allowsUndo = true
		return view
	}
	
	func updateNSView(_ nsView: NSTextView, context: Context) {
		nsView.textStorage?.beginEditing()
		defer { nsView.textStorage?.endEditing() }

		nsView.string = text

		let str = text as NSString
		nsView.textStorage?.setAttributes(.code, range: str.range)

		guard let attributes else { return }
		for (range, attrs) in attributes {
			nsView.textStorage?.addAttributes(attrs, range: range)
		}
	}

	func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSTextView, context: Context) -> CGSize? {
		guard let lm = nsView.layoutManager, let tc = nsView.textContainer else { return nil }
		lm.ensureLayout(for: tc)
		return lm.usedRect(for: tc).size
	}
}

typealias Attrs = [NSAttributedString.Key : Any]
typealias Attributes = [NSRange: Attrs]

extension Attrs {
	static var code: Attrs { [.font: NSFont.code] }
}

extension Font {
	static var code: Font { .system(size: 13).monospaced() }
}

extension NSFont {
	static var code: NSFont { NSFont.monospacedSystemFont(ofSize: 13, weight: .regular) }
}

extension NSString {
	var range: NSRange { .init(location: 0, length: length - 1) }
}
