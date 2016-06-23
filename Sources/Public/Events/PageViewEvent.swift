public struct PageViewEvent {

	public var advertisementProperties: AdvertisementProperties
	public var ecommerceProperties: EcommerceProperties
	public var pageProperties: PageProperties


	public init(
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.advertisementProperties = advertisementProperties
		self.ecommerceProperties = ecommerceProperties
		self.pageProperties = pageProperties
	}
}
