import SwiftUI
import ProgramCompiler

@main
struct Terminal: App {

    var body: some Scene {
        WindowGroup {
			ProgramView()
        }
    }
}

extension DispatchQueue {
	static let parsing = DispatchQueue(label: "parsing.queue")
	static let running = DispatchQueue(label: "running.queue")
}
