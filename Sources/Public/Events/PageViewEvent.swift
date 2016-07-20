public struct PageViewEvent:
	TrackingEventWithAdvertisementProperties,
	TrackingEventWithEcommerceProperties,
	TrackingEventWithPageProperties,
	TrackingEventWithSessionDetails
{

	public var advertisementProperties: AdvertisementProperties
	public var ecommerceProperties: EcommerceProperties
	public var pageProperties: PageProperties
	public var sessionDetails: [Int: TrackingValue]
	public var userProperties: UserProperties
	public var variables: [String : String]


	public init(
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(),
		variables: [String : String] = [:]
	) {
		self.advertisementProperties = advertisementProperties
		self.ecommerceProperties = ecommerceProperties
		self.pageProperties = pageProperties
		self.sessionDetails = sessionDetails
		self.userProperties = userProperties
		self.variables = variables
	}
}
