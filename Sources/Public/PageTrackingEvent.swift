public struct PageTrackingEvent {

	public var pageProperties: PageProperties
	public var ecommerceProperties: EcommerceProperties?
	public var userProperties: UserProperties?

	public init(pageProperties: PageProperties) {
		self.pageProperties = pageProperties
	}
}


public struct PageProperties {
	public var categories: Set<Category> = []
	public var page: Set<Category> = []
	public var pageName: String
	public var session: Set<Category> = []

	public init(pageName: String) {
		self.pageName = pageName
	}
}

extension PageProperties: Hashable {
	public var hashValue: Int {
		return categories.hashValue ^ page.hashValue ^ pageName.hashValue ^ session.hashValue
	}
}

public func ==(lhs: PageProperties, rhs: PageProperties) -> Bool {
	return lhs.categories == rhs.categories &&
	lhs.page == rhs.page &&
	lhs.pageName == rhs.pageName &&
	lhs.session == rhs.session
}