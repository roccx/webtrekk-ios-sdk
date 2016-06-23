public struct PageTrackingEvent {

	internal var advertisementProperties: AdvertisementProperties?
	internal var ecommerceProperties: EcommerceProperties?
	internal var pageProperties: PageProperties
	internal var userProperties: UserProperties?


	public init(advertisementProperties: AdvertisementProperties? = nil,
	            ecommerceProperties: EcommerceProperties? = nil,
	            pageProperties: PageProperties,
	            userProperties: UserProperties? = nil) {
		self.pageProperties = pageProperties
	}
}
