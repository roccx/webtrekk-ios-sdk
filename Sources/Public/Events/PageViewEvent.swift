public struct PageViewEvent:
	TrackingEventWithAdvertisementProperties,
	TrackingEventWithCustomProperties,
	TrackingEventWithEcommerceProperties,
	TrackingEventWithPageProperties
{

	public var advertisementProperties: AdvertisementProperties
	public var customProperties: [String : String]
	public var ecommerceProperties: EcommerceProperties
	public var pageProperties: PageProperties


	public init(
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		customProperties: [String : String] = [:],
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.advertisementProperties = advertisementProperties
		self.customProperties = customProperties
		self.ecommerceProperties = ecommerceProperties
		self.pageProperties = pageProperties
	}
}
