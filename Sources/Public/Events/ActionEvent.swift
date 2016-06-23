public struct ActionEvent {

	public var actionProperties: ActionProperties
	public var advertisementProperties: AdvertisementProperties
	public var customProperties: [String : String]
	public var ecommerceProperties: EcommerceProperties
	public var pageProperties: PageProperties


	public init(
		actionProperties: ActionProperties,
		pageProperties: PageProperties,
		customProperties: [String : String] = [:],
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.actionProperties = actionProperties
		self.advertisementProperties = advertisementProperties
		self.customProperties = customProperties
		self.ecommerceProperties = ecommerceProperties
		self.pageProperties = pageProperties
	}
}
