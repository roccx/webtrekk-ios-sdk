public struct AdvertisementProperties {

	public var action: String?
	public var details: [Int: TrackingValue]?
	public var id: String?


	public init(
		action: String? = nil,
		id: String?,
		details: [Int: TrackingValue]? = nil
	) {
		self.action = action
		self.details = details
		self.id = id
	}

	
	@warn_unused_result
	internal func merged(over other: AdvertisementProperties) -> AdvertisementProperties {
		return AdvertisementProperties(
			action: action ?? other.action,
			id:      id ?? other.id,
			details: details.merged(over: other.details)
		)
	}
}
