public protocol TrackingEvent {

	var pageName: String? { get mutating set }
	var userProperties: UserProperties { get mutating set }
	var variables: [String : String] { get mutating set }
	var viewControllerTypeName: String? { get mutating set }
}
