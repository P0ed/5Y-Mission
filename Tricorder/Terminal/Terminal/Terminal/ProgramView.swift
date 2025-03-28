import SwiftUI
import ProgramCompiler

struct ProgramView: View {
	@Environment(\.colorScheme) var colorScheme

	@State var program: String = UserDefaults.standard.string(forKey: "program")
		.flatMap { $0.isEmpty ? nil : $0 } ?? testProgram
	@State var output: String = ""
	@State var input: String = ""

	@State var running = false
	@State var editorHidden = false
	@State var consoleHidden = true
	@State var debug = true

	@State var scope: Scope?
	@State var executable: Program?

	@State var programChange: TimeInterval = .zero
	@State var outputChange: TimeInterval = .zero

	var consoleColor: Color { colorScheme == .light ? .consoleLight : .consoleDark }
	var overlayColor: Color { colorScheme == .light ? .overlayLight : .overlayDark }
	var tintColor: Color { colorScheme == .light ? .amberLight : .amberDark }

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
		.padding(.init(top: 8, leading: 16, bottom: editorHidden ? 0 : 8, trailing: 16))

		if !editorHidden {
			TextEditor(text: $program)
				.font(.code)
				.lineSpacing(4)
				.padding(.vertical, -8)
		}
		if !consoleHidden {
			ScrollView {
				ScrollViewReader { proxy in
					Text(output)
						.id("out")
						.font(.code)
						.lineSpacing(4)
						.onChange(of: output) { _, _ in
							let time = CACurrentMediaTime()
							let scroll = { proxy.scrollTo("out", anchor: .bottom) }
							if time - outputChange > 0.1 {
								withAnimation { scroll() }
							} else {
								scroll()
							}
							outputChange = time
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(4)
				}
			}
			.background(consoleColor)
			.contentMargins(.bottom, 24, for: .scrollContent)
			.overlay {
				VStack {
					Spacer()
					ZStack {
						overlayColor
							.frame(maxWidth: .infinity, maxHeight: 24, alignment: .bottom)

						TextField("", text: $input)
							.onSubmit { output += "\n\(input)"; input = "" }
							.textFieldStyle(.plain)
							.font(.code)
							.padding(.horizontal, 12)
							.frame(maxWidth: .infinity, maxHeight: 24)
					}
				}
			}
		}
    }

	func button(_ key: Character, _ active: Bool = false, _ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(.init("⌘ + \(String(key).uppercased())"))
				.font(.code)
				.padding(.horizontal, 4)
		}
		.buttonStyle(.accessoryBarAction)
		.keyboardShortcut(.init(key), modifiers: .command)
		.background(active ? tintColor : .clear)
		.background(in: .rect(cornerRadius: 6))
	}

	func build() {
		do {
			output = ""
			scope = nil
			executable = nil
			let scp = try Scope(program: program)
			scope = scp
			let program = try scp.compile()
			executable = program

			print("\(scp)\n\nprogram:\n\t\(program.description.aligned)\n")
		} catch {
			print("error:\n\t\(error)\n")
		}
	}

	func run() {
		guard !running else { return stop() }
		build()
		guard let executable, let scope else { return }
		running = true

		DispatchQueue.running.async {
			_ = executable.run(
				meta: scope,
				breakpoint: { pc, inn in
					var halt = 0 as Int32
					var throttle = false
					DispatchQueue.main.sync {
						halt = running ? 0 : 1
						throttle = debug
						if debug { print("\t\(inn.description(at: Int(pc)))\n") }
					}
					if throttle { usleep(1 << 13) }
					return halt
				},
				print: { x in DispatchQueue.main.async { print(x) } }
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
		if output.count > 1 << 12 {
			let s = output.split(separator: "\n", omittingEmptySubsequences: false)
			output = "\n" + s.dropFirst(s.count / 2).joined(separator: "\n")
		}
	}
}
