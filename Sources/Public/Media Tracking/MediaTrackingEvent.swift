public struct MediaTrackingEvent {

	public var ecommerceProperties: EcommerceProperties?
	public var kind: Kind
	public var mediaProperties: MediaProperties
	public var pageProperties: PageProperties?


	public init(kind: Kind, mediaProperties: MediaProperties) {
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
	}
}
