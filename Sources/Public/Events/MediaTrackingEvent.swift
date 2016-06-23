public struct MediaTrackingEvent {

	public var advertisementProperties: AdvertisementProperties
	public var ecommerceProperties: EcommerceProperties?
	public var kind: Kind
	public var mediaProperties: MediaProperties
	public var pageProperties: PageProperties


	public init(
		kind: Kind,
		mediaProperties: MediaProperties,
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties()
	) {
		self.mediaProperties = mediaProperties
		self.kind = kind
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
