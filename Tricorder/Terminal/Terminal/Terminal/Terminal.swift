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
