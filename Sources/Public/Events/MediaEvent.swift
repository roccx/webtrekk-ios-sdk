public struct MediaEvent: TrackingEvent {

	public var advertisementProperties: AdvertisementProperties
	public var customProperties: [String : String]
	public var ecommerceProperties: EcommerceProperties
	public var kind: Kind
	public var mediaProperties: MediaProperties
	public var pageProperties: PageProperties


	public init(
		kind: Kind,
		mediaProperties: MediaProperties,
		pageProperties: PageProperties,
		customProperties: [String : String] = [:],
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.advertisementProperties = advertisementProperties
		self.customProperties = customProperties
		self.ecommerceProperties = ecommerceProperties
		self.mediaProperties = mediaProperties
		self.kind = kind
		self.pageProperties = pageProperties
	}


	public enum Kind {

		case finish
		case pause
		case play
		case position
		case seek
		case stop
		case custom(name: String)
	}
}
