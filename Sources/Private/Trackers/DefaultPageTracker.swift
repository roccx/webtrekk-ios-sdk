import AVFoundation


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = protocol<ActionEventHandler, MediaEventHandler, PageViewEventHandler>

	private let handler: Handler
	
	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var customProperties = [String : String]()
	internal var ecommerceProperties = EcommerceProperties()
	internal var pageProperties: PageProperties


	internal init(handler: Handler, pageName: String) {
		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal init(handler: Handler, viewControllerTypeName: String) {
		self.handler = handler

		self.pageProperties = PageProperties(viewControllerTypeName: viewControllerTypeName)
	}


	internal func trackAction(event: ActionEvent) {
		handleEvent(event)
	}


	internal func trackMedia(event: MediaEvent) {
		handleEvent(event)
	}


	@warn_unused_result
	internal func trackMedia(mediaName: String) -> MediaTracker {
		return DefaultMediaTracker(handler: self, mediaName: mediaName)
	}


	internal func trackMedia(mediaName: String, byAttachingToPlayer player: AVPlayer) -> MediaTracker {
		let tracker = trackMedia(mediaName)
		AVPlayerTracker.track(player: player, with: tracker)

		return tracker
	}


	internal func trackPageView() {
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
		var event = event
		event.advertisementProperties = event.advertisementProperties.merged(over: advertisementProperties)
		event.customProperties = event.customProperties.merged(over: customProperties)
		event.ecommerceProperties = event.ecommerceProperties.merged(over: ecommerceProperties)
		event.pageProperties = event.pageProperties.merged(over: pageProperties)

		handler.handleEvent(event)
	}
}
