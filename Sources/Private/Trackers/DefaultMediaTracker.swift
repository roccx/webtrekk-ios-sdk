internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaEventHandler

	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var ecommerceProperties = EcommerceProperties()
	internal var mediaProperties: MediaProperties
	internal var pageProperties = PageProperties(name: nil)


	internal init(handler: MediaEventHandler, mediaName: String, mediaCategories: Set<Category>?) {
		self.handler = handler
		self.mediaProperties = MediaProperties(name: mediaName, categories: mediaCategories)
	}


	internal func trackEvent(kind: MediaEvent.Kind) {
		handler.handleEvent(MediaEvent(kind: kind, mediaProperties: mediaProperties, pageProperties: pageProperties))
	}
}
