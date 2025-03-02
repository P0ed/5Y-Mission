import SwiftUI

struct ContentView: View {
	@State
	var program: String = ""

    var body: some View {
        VStack {
			TextEditor(text: $program)
        }
        .padding()
    }
}
