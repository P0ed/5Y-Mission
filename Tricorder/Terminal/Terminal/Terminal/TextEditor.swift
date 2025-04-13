import SwiftUI
import AppKit

struct TextEditor: NSViewRepresentable {
	@Binding var text: String
	@Binding var attributes: Attributes?

	func makeNSView(context: Context) -> NSTextEditor {
		let view = NSTextEditor()
		view.textView.allowsUndo = true
		view.textView.delegate = view.delegate
		view.textView.drawsBackground = false
		view.textView.font = .code
		view.delegate.textChanged = { attributes = nil; text = $0 }

		view.hasVerticalScroller = true
		view.hasHorizontalScroller = false
		view.drawsBackground = false

		view.documentView = view.textView
		view.textView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.textView.widthAnchor.constraint(equalTo: view.widthAnchor),
			view.textView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
		])

		return view
	}

	func updateNSView(_ nsView: NSTextEditor, context: Context) {
		nsView.textView.textStorage?.beginEditing()
		defer { nsView.textView.textStorage?.endEditing() }

		if nsView.textView.string != text { nsView.textView.string = text }

		let str = text as NSString
		nsView.textView.textStorage?.setAttributes(.code, range: str.range)

		guard let attributes else { return }
		for (range, attrs) in attributes {
			nsView.textView.textStorage?.addAttributes(attrs, range: range)
		}
	}
}

final class NSTextEditor: NSScrollView {
	let textView = NSTextView()
	let delegate = TextViewDelegate()
}

final class TextViewDelegate: NSObject, NSTextViewDelegate {
	var textChanged: (String) -> Void = { _ in }

	func textDidChange(_ notification: Notification) {
		if let view = notification.object as? NSTextView { textChanged(view.string) }
	}
}

typealias Attrs = [NSAttributedString.Key : Any]
typealias Attributes = [NSRange: Attrs]

extension Attrs {
	static var code: Attrs { [.font: NSFont.code, .foregroundColor: NSColor.txt0] }
}

extension Font {
	static var code: Font { .system(size: 13).monospaced() }
}

extension NSFont {
	static var code: NSFont { NSFont.monospacedSystemFont(ofSize: 13, weight: .regular) }
}

extension NSString {
	var range: NSRange { .init(location: 0, length: max(0, length - 1)) }
}
