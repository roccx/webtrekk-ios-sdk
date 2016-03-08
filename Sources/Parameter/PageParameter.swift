import Foundation

public struct PageParameter {
	public var page:       [Int: String]
	public var categories: [Int: String]
	public var session:    [Int: String]

	public init(categories: [Int: String] = [Int: String](), page: [Int: String] = [Int: String](), session: [Int: String] = [Int: String]()){
		self.categories = categories
		self.page = page
		self.session = session
	}
}

extension PageParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = ""

			if !page.isEmpty {
				for (index, value) in page {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .Page, withIndex: index, andValue: value))"
				}


			}

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .PageCategory, withIndex: index, andValue: value))"
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



