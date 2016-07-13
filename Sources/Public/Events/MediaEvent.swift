public struct MediaEvent: TrackingEventWithMediaProperties {

	public var action: Action
	public var mediaProperties: MediaProperties
	public var pageName: String?
	public var viewControllerTypeName: String?


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		pageName: String?
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.pageName = pageName
	}


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		viewControllerTypeName: String?
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.viewControllerTypeName = viewControllerTypeName
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
