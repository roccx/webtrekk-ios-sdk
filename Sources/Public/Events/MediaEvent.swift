public struct MediaEvent: TrackingEventWithMediaProperties {

	public var action: Action
	public var ipAddress: String?
	public var mediaProperties: MediaProperties
	public var pageName: String?
	public var variables: [String : String]
	public var viewControllerTypeName: String?


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		pageName: String?,
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.pageName = pageName
		self.variables = variables
	}


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		viewControllerTypeName: String?,
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.variables = variables
		self.viewControllerTypeName = viewControllerTypeName
	}



	public enum Action {

		case finish
		case initialize
		case pause
		case play
		case position
		case seek
		case stop
		case custom(name: String)
	}
}
