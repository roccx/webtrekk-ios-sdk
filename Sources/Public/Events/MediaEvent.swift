public struct MediaEvent: TrackingEvent {

	public var action: Action
	public var advertisementProperties: AdvertisementProperties
	public var customProperties: [String : String]
	public var ecommerceProperties: EcommerceProperties
	public var mediaProperties: MediaProperties
	public var pageProperties: PageProperties


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		pageProperties: PageProperties,
		customProperties: [String : String] = [:],
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.action = action
		self.advertisementProperties = advertisementProperties
		self.customProperties = customProperties
		self.ecommerceProperties = ecommerceProperties
		self.mediaProperties = mediaProperties
		self.pageProperties = pageProperties
	}



	public enum Action {

		case finish
		case pause
		case play
		case position
		case seek
		case stop
		case custom(name: String)
	}
}
