import SwiftUI

@main
struct Terminal: App {

    var body: some Scene {
        WindowGroup {
			ProgramView()
        }
    }
}

extension DispatchQueue {
	static let running = DispatchQueue(label: "running.queue")
}

extension Font {
	static var code: Font { .system(size: 13).monospaced() }
}
