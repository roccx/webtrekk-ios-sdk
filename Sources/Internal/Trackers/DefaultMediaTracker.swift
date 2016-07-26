import UIKit


internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaEventHandler

	internal var mediaProperties: MediaProperties
	internal var pageName: String?
	internal var variables = [String : String]()
	internal var viewControllerType: UIViewController.Type?


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
		event.viewControllerType = viewControllerType

		handler.handleEvent(event)
	}
}
