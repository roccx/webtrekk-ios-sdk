import Foundation

public protocol ActionParameter {
	var name:       String        { get }
	var categories: [Int: String] { get set }
	var session:    [Int: String] { get set }
}

internal struct DefaultActionParameter: ActionParameter {
	internal let name:       String
	internal var categories: [Int: String]
	internal var session:    [Int: String]

	internal init(categories: [Int: String] = [Int: String](), name: String, session:   [Int: String] = [Int: String]()) {
		guard !name.isEmpty else {
			fatalError("name cannot be empty")
		}
		self.name = name
		self.categories = categories
		self.session = session
	}
}