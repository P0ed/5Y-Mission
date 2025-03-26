import SwiftUI
import ProgramCompiler

struct ProgramView: View {
	@State
	var program: String = testProgram
	@State
	var tree: String = ""
	@State
	var bytecode: String = ""
	@State
	var editorHidden = false
	@State
	var consoleHidden = false
	@State
	var output: String = ""
	@State
	var executable: Program?

	func btn(_ key: Character, _ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(.init("⌘ + \(String(key).uppercased())"))
		}
		.keyboardShortcut(.init(key), modifiers: .command)
	}

    var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 12) {
				btn("b", build)
				btn("r", run)
				btn("u", {})
				Spacer()
				btn("k") { output = "" }
				btn("e") { editorHidden.toggle(); consoleHidden = editorHidden ? false : consoleHidden }
				btn("t")  { consoleHidden.toggle(); editorHidden = consoleHidden ? false : editorHidden }
			}
			.padding(.init(top: 8, leading: 12, bottom: 0, trailing: 12))

			if !editorHidden {
				TextEditor(text: $program)
					.font(.system(size: 16).monospaced())
					.lineSpacing(4)
			}
			if !consoleHidden {
				TextEditor(text: $output)
					.font(.system(size: 16).monospaced())
					.lineSpacing(4)
			}
		}
    }

	func build() {
		tree = ""
		bytecode = ""
		executable = nil

		do {
			let scope = try Scope(program: program)

			let types = scope.types.map { ($0.key, $0.value) }
				.sorted { $0.0 < $1.0 }
				.map { "\t\($0): \($1.resolvedDescription)" }
				.joined(separator: "\n")
			let funcs = scope.funcs
				.map { "\t\($0.description.replacingOccurrences(of: "\n", with: "\n\t\t"))" }
				.joined(separator: "\n")
			let vars = scope.vars
				.map { "\t\($0)" }
				.joined(separator: "\n")
			let exprs = scope.exprs
				.map { "\t\($0)" }
				.joined(separator: "\n")

			tree = "types:\n\(types)\nfuncs:\n\(funcs)\nvars:\n\(vars)\nexprs:\n\(exprs)"

			let program = try scope.compile()
			executable = program
			bytecode = program.description
			output = tree + "\ncode:\n\t" + bytecode.replacingOccurrences(of: "\n", with: "\n\t")
		} catch {
			output = (error as? CompilationError)?.description ?? error.localizedDescription
		}
	}

	func run() {
		build()
		if let executable {
			let result = executable.run {
				output += $0
			}
			output += "\nexit:\n\t\(result)"
		}
	}
}
