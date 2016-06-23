import AVFoundation


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = protocol<ActionEventHandler, MediaEventHandler, PageViewEventHandler>

	private let handler: Handler
	
	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var ecommerceProperties = EcommerceProperties()
	internal var pageProperties: PageProperties


	internal init(handler: Handler, pageName: String) {
		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal func trackAction(name name: String) {
		trackAction(properties: ActionProperties(name: name))
	}


	internal func trackAction(properties properties: ActionProperties) {
		handler.handleEvent(ActionEvent(actionProperties: properties, pageProperties: pageProperties))
	}


	internal func trackPageView() {
		handler.handleEvent(PageViewEvent(
			pageProperties:          pageProperties,
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties
		))
	}


	internal func trackerForMedia(name name: String, player: AVPlayer) {
		return trackerForMedia(name: name, categories: nil, player: player)
	}


	internal func trackerForMedia(name name: String, categories: Set<Category>?, player: AVPlayer) {
		AVPlayerTracker.track(
			player: player,
			with:   DefaultMediaTracker(handler: self, mediaName: name, mediaCategories: categories)
		)
	}
}


extension DefaultPageTracker: MediaEventHandler {

	internal func handleEvent(event: MediaEvent) {
		var event = event
		event.advertisementProperties = event.advertisementProperties.merged(with: advertisementProperties)
		event.ecommerceProperties = event.ecommerceProperties.merged(with: ecommerceProperties)
		event.pageProperties = event.pageProperties.merged(with: pageProperties)

		handler.handleEvent(event)
	}
}
