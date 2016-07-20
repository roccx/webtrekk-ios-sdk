public struct MediaEvent: TrackingEventWithMediaProperties {

	public var action: Action
	public var mediaProperties: MediaProperties
	public var pageName: String?
	public var sessionDetails: [Int: TrackingValue]
	public var userProperties: UserProperties
	public var variables: [String : String]
	public var viewControllerTypeName: String?


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		pageName: String?,
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(),
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.pageName = pageName
		self.sessionDetails = sessionDetails
		self.userProperties = userProperties
		self.variables = variables
	}


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		viewControllerTypeName: String?,
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(),
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.sessionDetails = sessionDetails
		self.userProperties = userProperties
		self.variables = variables
		self.viewControllerTypeName = viewControllerTypeName
	}



	public enum Action {

		case created
		case finish
		case pause
		case play
		case position
		case seek
		case stop
		case custom(name: String)
	}
}
