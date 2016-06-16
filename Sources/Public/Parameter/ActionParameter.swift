import Foundation

public struct ActionParameter {
	public var name:       String
	public var categories: [Int: String]
	public var session:    [Int: String]

	public init(categories: [Int: String] = [:],
	            name: String,
	            session: [Int: String] = [:]) {
		guard !name.isEmpty else {
			fatalError("name cannot be empty")
		}
		self.name = name
		self.categories = categories
		self.session = session
	}
}