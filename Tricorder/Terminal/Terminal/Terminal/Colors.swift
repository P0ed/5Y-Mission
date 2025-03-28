import SwiftUI

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
