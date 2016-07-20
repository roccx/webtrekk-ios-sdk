internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaEventHandler

	internal var mediaProperties: MediaProperties
	internal var pageName: String?
	internal var variables = [String : String]()
	internal var viewControllerTypeName: String?


	internal init(handler: MediaEventHandler, mediaName: String, pageName: String?) {
		checkIsOnMainThread()

		self.handler = handler
		self.mediaProperties = MediaProperties(name: mediaName)
		self.pageName = pageName
	}


	internal func trackAction(action: MediaEvent.Action) {
		checkIsOnMainThread()

		var event = MediaEvent(
			action:          action,
			mediaProperties: mediaProperties,
			pageName:        pageName,
			variables:       variables
		)
		event.viewControllerTypeName = viewControllerTypeName

		handler.handleEvent(event)
	}
}
