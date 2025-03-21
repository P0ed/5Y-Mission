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

    var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 12) {
				Button(action: build) {
					Text(.init("⌘ + B"))
				}
				.keyboardShortcut(.init("b"), modifiers: .command)
				Button(action: run) {
					Text(.init("⌘ + R"))
				}
				.keyboardShortcut(.init("r"), modifiers: .command)
				Button(action: {}) {
					Text(.init("⌘ + U"))
				}
				.keyboardShortcut(.init("u"), modifiers: .command)
				Spacer()
				Button(action: {
					editorHidden.toggle()
					consoleHidden = editorHidden ? false : consoleHidden
				}) {
					Text(.init("⌘ + E"))
				}
				.keyboardShortcut(.init("e"), modifiers: .command)
				Button(action: {
					consoleHidden.toggle()
					editorHidden = consoleHidden ? false : editorHidden
				}) {
					Text(.init("⌘ + T"))
				}
				.keyboardShortcut(.init("t"), modifiers: .command)
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

			let types = scope.types
				.sorted { $0.key < $1.key }
				.map { "\t\($0): \($1.resolvedDescription)" }
				.joined(separator: "\n")
			let vars = scope.vars
				.map { "\t\($0)" }
				.joined(separator: "\n")
			let exprs = scope.exprs
				.map { "\t\($0)" }
				.joined(separator: "\n")
			
			tree = "types:\n\(types)\nvars:\n\(vars)\nexprs:\n\(exprs)"

			let program = try scope.compile()
			executable = program
			bytecode = program.rawData.map(\.description).joined(separator: "\n")
			output = tree + "\n= = = = = = = = = = = =\n" + bytecode
		} catch {
			output = (error as? CompilationError)?.description ?? error.localizedDescription
		}
	}

	func run() {
		build()
		if let executable { output += "\nexit(\(executable.run()))" }
	}
}
