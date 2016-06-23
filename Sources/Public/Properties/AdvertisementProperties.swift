public struct AdvertisementProperties {

	public var categories: Set<Category>?
	public var id: String?


	public init(
		id: String?,
		categories: Set<Category>? = nil
	) {
		self.categories = categories
		self.id = id
	}
}
