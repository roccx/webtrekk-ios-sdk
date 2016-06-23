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

	
	@warn_unused_result
	internal func merged(with other: AdvertisementProperties) -> AdvertisementProperties {
		return AdvertisementProperties(
			id:         id ?? other.id,
			categories: categories ?? other.categories
		)
	}
}
