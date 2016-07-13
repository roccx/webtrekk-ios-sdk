public protocol TrackingEvent {

	var pageName: String? { get mutating set }
	var viewControllerTypeName: String? { get mutating set }
}
