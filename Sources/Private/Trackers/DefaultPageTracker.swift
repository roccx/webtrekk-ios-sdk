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
			customProperties:        customProperties,
			ecommerceProperties:     ecommerceProperties
		))
	}


	internal func trackerForMedia(name name: String, player: AVPlayer) {
		return trackerForMedia(name: name, groups: nil, player: player)
	}


	internal func trackerForMedia(name name: String, groups: Set<IndexedProperty>?, player: AVPlayer) {
		AVPlayerTracker.track(
			player: player,
			with:   DefaultMediaTracker(handler: self, mediaName: name, mediaGroups: groups)
		)
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
