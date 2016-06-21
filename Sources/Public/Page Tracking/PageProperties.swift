public struct PageProperties {

	public var categories = Set<Category>()
	public var name: String
	public var page = Set<Category>()
	public var session = Set<Category>()


	public init(name: String) {
		self.name = name
	}
}


extension PageProperties: Hashable {

	public var hashValue: Int {
		return categories.hashValue ^ name.hashValue ^ page.hashValue ^ session.hashValue
	}
}


public func == (a: PageProperties, b: PageProperties) -> Bool {
	return a.categories == b.categories
		&& a.name == b.name
		&& a.page == b.page
		&& a.session == b.session
}
