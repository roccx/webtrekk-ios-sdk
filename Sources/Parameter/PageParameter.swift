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

