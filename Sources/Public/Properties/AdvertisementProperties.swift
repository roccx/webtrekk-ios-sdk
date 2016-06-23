public struct AdvertisementProperties {

	public var details: Set<IndexedProperty>?
	public var id: String?


	public init(
		id: String?,
		details: Set<IndexedProperty>? = nil
	) {
		self.details = details
		self.id = id
	}

	
	@warn_unused_result
	internal func merged(over other: AdvertisementProperties) -> AdvertisementProperties {
		return AdvertisementProperties(
			id:      id ?? other.id,
			details: details ?? other.details
		)
	}
}
