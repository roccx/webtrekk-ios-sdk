import AVFoundation


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = protocol<ActionEventHandler, MediaEventHandler, PageViewEventHandler>

	private let handler: Handler
	
	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var customProperties = [String : String]()
	internal var ecommerceProperties = EcommerceProperties()
	internal var pageProperties: PageProperties


	internal init(handler: Handler, pageName: String) {
		checkIsOnMainThread()

		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal init(handler: Handler, viewControllerTypeName: String) {
		checkIsOnMainThread()

		self.handler = handler

		self.pageProperties = PageProperties(viewControllerTypeName: viewControllerTypeName)
	}


	internal func trackAction(event: ActionEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	internal func trackMedia(event: MediaEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	@warn_unused_result
	internal func trackMedia(mediaName: String) -> MediaTracker {
		checkIsOnMainThread()

		return DefaultMediaTracker(handler: self, mediaName: mediaName)
	}


	internal func trackMedia(mediaName: String, byAttachingToPlayer player: AVPlayer) -> MediaTracker {
		checkIsOnMainThread()

		let tracker = trackMedia(mediaName)
		AVPlayerTracker.track(player: player, with: tracker)

		return tracker
	}


	internal func trackPageView() {
		checkIsOnMainThread()

		handler.handleEvent(PageViewEvent(
			pageProperties:          pageProperties,
			advertisementProperties: advertisementProperties,
			customProperties:        customProperties,
			ecommerceProperties:     ecommerceProperties
		))
	}
}


extension DefaultPageTracker: ActionEventHandler {

	internal func handleEvent(event: ActionEvent) {
		checkIsOnMainThread()

		var event = event
		event.advertisementProperties = event.advertisementProperties.merged(over: advertisementProperties)
		event.customProperties = event.customProperties.merged(over: customProperties)
		event.ecommerceProperties = event.ecommerceProperties.merged(over: ecommerceProperties)
		event.pageProperties = event.pageProperties.merged(over: pageProperties)

		handler.handleEvent(event)
	}
}


extension DefaultPageTracker: MediaEventHandler {

	internal func handleEvent(event: MediaEvent) {
		checkIsOnMainThread()

		var event = event
		event.advertisementProperties = event.advertisementProperties.merged(over: advertisementProperties)
		event.customProperties = event.customProperties.merged(over: customProperties)
		event.ecommerceProperties = event.ecommerceProperties.merged(over: ecommerceProperties)
		event.pageProperties = event.pageProperties.merged(over: pageProperties)

		handler.handleEvent(event)
	}
}
