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
	static let running = DispatchQueue(label: "running.queue")
}

extension String {

	static var savedProgram: String {
		UserDefaults.standard.string(forKey: "program")
			.flatMap { $0.isEmpty ? nil : $0 } ?? testProgram
	}
}
