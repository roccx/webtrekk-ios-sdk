public struct GlobalProperties {
	
	public var actionProperties: ActionProperties
	public var advertisementProperties: AdvertisementProperties
	public var crossDeviceProperties: CrossDeviceProperties
	public var ecommerceProperties: EcommerceProperties
	public var ipAddress: String?
	public var mediaProperties: MediaProperties
	public var pageProperties: PageProperties
	public var sessionDetails: [Int: TrackingValue]
	public var userProperties: UserProperties


	public init(
		actionProperties: ActionProperties = ActionProperties(name: nil),
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		crossDeviceProperties: CrossDeviceProperties = CrossDeviceProperties(),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		ipAddress: String? = nil,
		mediaProperties: MediaProperties = MediaProperties(name: nil),
		pageProperties: PageProperties = PageProperties(name: nil),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties()
	) {
		self.actionProperties = actionProperties
		self.advertisementProperties = advertisementProperties
		self.crossDeviceProperties = crossDeviceProperties
		self.ecommerceProperties = ecommerceProperties
		self.ipAddress = ipAddress
		self.mediaProperties = mediaProperties
		self.pageProperties = pageProperties
		self.sessionDetails = sessionDetails
		self.userProperties = userProperties
	}
}
