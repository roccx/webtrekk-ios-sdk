internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaEventHandler

	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var customProperties = [String : String]()
	internal var ecommerceProperties = EcommerceProperties()
	internal var mediaProperties: MediaProperties
	internal var pageProperties: PageProperties


	internal init(handler: MediaEventHandler, mediaName: String, pageName: String?) {
		checkIsOnMainThread()

		self.handler = handler
		self.mediaProperties = MediaProperties(name: mediaName)
		self.pageProperties = PageProperties(name: pageName)
	}


	internal func trackAction(action: MediaEvent.Action) {
		checkIsOnMainThread()

		handler.handleEvent(MediaEvent(
			action:                   action,
			mediaProperties:          mediaProperties,
			pageProperties:           pageProperties,
			customProperties:         customProperties,
			advertisementProperties:  advertisementProperties,
			ecommerceProperties:      ecommerceProperties
		))
	}
}
