import SwiftUI
import ProgramCompiler

struct ProgramView: View {
	@Environment(\.colorScheme) var colorScheme

	@State var program: String = UserDefaults.standard.string(forKey: "program")
		.flatMap { $0.isEmpty ? nil : $0 } ?? testProgram
	@State var input: String = ""
	@State var output: String = ""

	@State var debug = true
	@State var editorHidden = false
	@State var consoleHidden = true
	@State var running = false
	@State var executable: Program?
	@State var meta: Scope?
	@State var lastChange: TimeInterval = .zero

	var darkBackground: Color {
		colorScheme == .light ? Color(white: 0.96) : Color(white: 0.13)
	}
	var lightBackground: Color {
		colorScheme == .light ? Color(white: 0.98, opacity: 0.88) : Color(white: 0.14, opacity: 0.92)
	}

    var body: some View {
		HStack(spacing: 12) {
			button("s") { UserDefaults.standard.set(program, forKey: "program") }
			button("b") { build() }
			button("r") { run() }
			button(".") { stop() }
			Spacer()
			button("k") { output = "" }
			button("e", !editorHidden) { editorHidden.toggle(); consoleHidden = editorHidden ? false : consoleHidden }
			button("t", !consoleHidden) { consoleHidden.toggle(); editorHidden = consoleHidden ? false : editorHidden }
			button("d", debug, { debug.toggle() })
		}
		.padding(.init(top: 8, leading: 12, bottom: editorHidden ? 8 : 0, trailing: 12))

		if !editorHidden {
			TextEditor(text: $program)
				.font(.system(size: 14).monospaced())
				.lineSpacing(4)
		}
		if !consoleHidden {
			ZStack {
				ScrollView {
					ScrollViewReader { proxy in
						Text(output)
							.id("out")
							.font(.system(size: 14).monospaced())
							.lineSpacing(4)
							.onChange(of: output) { _, _ in
								let time = CACurrentMediaTime()
								let scroll = { proxy.scrollTo("out", anchor: .bottom) }
								if time - lastChange > 0.1 {
									withAnimation { scroll() }
								} else {
									scroll()
								}
								lastChange = time
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(4)
							.onTapGesture {
								NSPasteboard.general.declareTypes([.string], owner: nil)
								NSPasteboard.general.setString(output, forType: .string)
							}
					}
				}
				.contentMargins(.bottom, 24, for: .scrollContent)

				VStack {
					Spacer()
					ZStack {
						lightBackground
							.frame(maxWidth: .infinity, maxHeight: 24, alignment: .bottom)

						TextField("", text: $input)
							.onSubmit { output += "\n\(input)"; input = "" }
							.textFieldStyle(.plain)
							.font(.system(size: 14).monospaced())
							.padding(.horizontal, 12)
							.frame(maxWidth: .infinity, maxHeight: 24)
					}
				}
			}
			.background(darkBackground)
		}
    }

	func button(_ key: Character, _ active: Bool = false, _ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(.init("⌘ + \(String(key).uppercased())"))
		}
		.keyboardShortcut(.init(key), modifiers: .command)
		.background(active ? Color.brown.opacity(0.6) : Color.clear)
		.background(in: .rect(cornerRadius: 6))
	}

	func build() {
		do {
			meta = nil
			executable = nil
			let scope = try Scope(program: program)
			meta = scope
			let program = try scope.compile()
			executable = program

			print((output.isEmpty ? "" : "\n") + "\(scope)\n\nprogram:\n\t\(program.description.aligned)\n")
		} catch {
			let descr = ((error as? CompilationError)?.description ?? error.localizedDescription)
			print((output.isEmpty ? "" : "\n") + "error:\n\t\(descr)\n")
		}
	}

	func run() {
		build()

		guard let executable, let meta, !running else { return }
		running = true

		DispatchQueue.running.async {
			_ = executable.run(
				meta: meta,
				breakpoint: { pc, inn in
					var halt = 0 as Int32
					var throttle = false
					DispatchQueue.main.sync {
						halt = running ? 0 : 1
						if debug { print("\t\(inn.description(at: Int(pc)))\n") }
						throttle = debug
					}
					if throttle { usleep(1 << 14) }
					return halt
				},
				print: { x in
					DispatchQueue.main.async { print(x) }
				}
			)
			DispatchQueue.main.async { running = false }
		}
	}

	func stop() {
		running = false
	}

	func print(_ str: String) {
		consoleHidden = false

		output += str
		if output.count > 1 << 11 {
			let s = output.split(separator: "\n", omittingEmptySubsequences: false)
			output = "\n" + s.dropFirst(s.count / 2).joined(separator: "\n")
		}
	}
}
