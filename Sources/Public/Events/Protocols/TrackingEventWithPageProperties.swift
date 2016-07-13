public protocol TrackingEventWithPageProperties: TrackingEvent {

	var pageProperties: PageProperties { get mutating set }
}


public extension TrackingEventWithPageProperties {

	public var pageName: String? {
		get { return pageProperties.name }
		mutating set { pageProperties.name = newValue }
	}


	public var viewControllerTypeName: String? {
		get { return pageProperties.viewControllerTypeName }
		mutating set { pageProperties.viewControllerTypeName = newValue }
	}
}
