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
			var urlParameter = "\(ParameterName.ActionName.rawValue)=\(name)"
			if !categories.isEmpty {
				for (key, value) in categories {
					urlParameter += "&\(ParameterName.ActionCategory.rawValue)\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
				}
			}
			if !session.isEmpty {
				for (key, value) in session {
					urlParameter += "&\(ParameterName.Session.rawValue)\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
				}
			}
			return urlParameter
		}
	}
}
