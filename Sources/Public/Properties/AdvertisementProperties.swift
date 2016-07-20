public struct AdvertisementProperties {

	public var details: [Int: TrackingValue]?
	public var id: String?


	public init(
		id: String?,
		details: [Int: TrackingValue]? = nil
	) {
		self.details = details
		self.id = id
	}

	
	@warn_unused_result
	internal func merged(over other: AdvertisementProperties) -> AdvertisementProperties {
		return AdvertisementProperties(
			id:      id ?? other.id,
			details: details.merged(over: other.details)
		)
	}
}
