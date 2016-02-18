import Foundation

public protocol PageParameter {
	var page:       [Int: String] { get set }
	var categories: [Int: String] { get set }
	var session:    [Int: String] { get set }
}

internal struct DefaultPageParameter: PageParameter {
	internal var page:       [Int: String]
	internal var categories: [Int: String]
	internal var session:    [Int: String]

	internal init(categories: [Int: String] = [Int: String](), page: [Int: String] = [Int: String](), session: [Int: String] = [Int: String]()){
		self.categories = categories
		self.page = page
		self.session = session
	}
}

