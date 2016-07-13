public protocol MediaTracker: class {

	var mediaProperties: MediaProperties { get set }
	var pageName: String? { get set }
	var viewControllerTypeName: String? { get set }

	func trackAction (action: MediaEvent.Action)
}
