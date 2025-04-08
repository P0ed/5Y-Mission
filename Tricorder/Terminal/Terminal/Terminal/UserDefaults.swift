import Foundation

extension UserDefaults {

	var savedProgram: String {
		get {
			string(forKey: "program").flatMap { $0.isEmpty ? nil : $0 } ?? testProgram
		}
		set {
			setValue(newValue, forKey: "program")
		}
	}

	var debugEnabled: Bool {
		get {
			bool(forKey: "debug")
		}
		set {
			setValue(newValue, forKey: "debug")
		}
	}
}
