import Foundation

public struct ActionParameter {
	public let name:       String
	public var categories: [Int: String]
	public var session:    [Int: String]

	public init(categories: [Int: String] = [Int: String](), name: String, session:   [Int: String] = [Int: String]()) {
		guard !name.isEmpty else {
			fatalError("name cannot be empty")
		}
		self.name = name
		self.categories = categories
		self.session = session
	}
}

extension ActionParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = ParameterName.urlParameter(fromName: .ActionName, andValue: name)

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .ActionCategory, withIndex: index, andValue: value))"
				}
			}

			if !session.isEmpty {
				for (index, value) in session {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .Session, withIndex: index, andValue: value))"
				}
			}
			return urlParameter
		}
	}
}
