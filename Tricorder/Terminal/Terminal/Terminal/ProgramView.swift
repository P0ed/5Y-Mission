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
	var output: String = ""
	@State
	var executable: Program?

    var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Button(action: build) {
					Text(.init("⌘ + B"))
				}
				.keyboardShortcut(.init("b"), modifiers: .command)
				Button(action: run) {
					Text(.init("⌘ + R"))
				}
				.keyboardShortcut(.init("r"), modifiers: .command)
			}
			.padding(.init(top: 12, leading: 12, bottom: 4, trailing: 12))

			TextEditor(text: $program)
				.font(.system(size: 16).monospaced())
				.lineSpacing(4)

			TextEditor(text: $output)
				.font(.system(size: 16).monospaced())
				.lineSpacing(4)
		}
    }

	func build() {
		do {
			let stmt = try Stmt(program: program)
			tree = "\(stmt)"
			let program = try stmt.compile()
			executable = program
			bytecode = program.rawData.map(\.description).joined(separator: "\n")
			output = tree + "\n= = = = = = = = = = = =\n" + bytecode
		} catch let error as TreeParsingError {
			executable = nil
			tree = error.description
			bytecode = ""
			output = tree
		} catch let error as CompilationError {
			executable = nil
			bytecode = error.description
			output = tree + "\n= = = = = = = = = = = =\n" + bytecode
		} catch {
			executable = nil
			output = "Unknown error: \(error.localizedDescription)"
		}
	}

	func run() {
		executable?.run()
	}
}

let testProgram = """
int cnt = 0;

// type def static array of chars 32 elements long
string = char 32;

// struct decl
person = (
	string name,
	string email,
	(string public, string prvivate) keys
);

// function def
void <- int incCnt = { x | cnt = cnt + x };

int <- int square = { x | x * 2 };

int <- person lenx = { x |

	void <- void side_effect = { | };

	char 62 sum = x.name + x.email;
	count sum
};

int <- person len = {
	count # name + email
};

person p = (name: "Kostya", email: "x@y.z");
int l = len p;
int lx = p.len;
len (name: "Katya", email: "xxx@yyy.zzz")

"""
