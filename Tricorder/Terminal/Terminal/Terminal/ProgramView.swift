import SwiftUI
import ProgramCompiler

struct ProgramView: View {
	@State var program: String = UserDefaults.standard.string(forKey: "program")
		.flatMap { $0.isEmpty ? nil : $0 } ?? testProgram
	@State var output: String = ""

	@State var editorHidden = false
	@State var consoleHidden = false
	@State var executable: Program?
	@State var meta: Scope?

    var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 12) {
				button("s", { UserDefaults.standard.set(program, forKey: "program") })
				button("b", build)
				button("r", run)
				Spacer()
				button("k") { output = "" }
				button("e") { editorHidden.toggle(); consoleHidden = editorHidden ? false : consoleHidden }
				button("t")  { consoleHidden.toggle(); editorHidden = consoleHidden ? false : editorHidden }
			}
			.padding(.init(top: 8, leading: 12, bottom: 0, trailing: 12))

			if !editorHidden {
				TextEditor(text: $program)
					.font(.system(size: 14).monospaced())
					.lineSpacing(4)
			}
			if !consoleHidden {
				TextEditor(text: $output)
					.font(.system(size: 14).monospaced())
					.lineSpacing(4)
			}
		}
    }

	func button(_ key: Character, _ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(.init("⌘ + \(String(key).uppercased())"))
		}
		.keyboardShortcut(.init(key), modifiers: .command)
	}

	func build() {
		executable = nil

		do {
			let scope = try Scope(program: program)
			meta = scope

			let program = try scope.compile()
			executable = program

			output += (output.isEmpty ? "" : "\n") + "\(scope)\n\nprogram:\n\t\(program.description.aligned)\n"
		} catch {
			let descr = ((error as? CompilationError)?.description ?? error.localizedDescription)
			output += (output.isEmpty ? "" : "\n") + "error:\n\t\(descr)\n"
		}
	}

	func run() {
		build()
		_ = executable?.run(meta) { output += $0 }
	}
}
