import AVFoundation


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = protocol<ActionTrackingEventHandler, MediaTrackingEventHandler, PageTrackingEventHandler>

	private let handler: Handler
	
	internal var advertisementProperties: AdvertisementProperties?
	internal var ecommerceProperties: EcommerceProperties?
	internal var pageProperties: PageProperties
	internal var userProperties: UserProperties?

	internal init(handler: Handler, pageName: String) {
		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal func trackAction(actionName: String) {
		trackAction(ActionProperties(name: actionName))
	}


	internal func trackAction(actionProperties: ActionProperties) {
		handler.handleEvent(ActionTrackingEvent(actionProperties: actionProperties))
	}


	internal func trackMedia(mediaName: String, player: AVPlayer) {
		return trackMedia(mediaName, mediaCategories: [], player: player)
	}


	internal func trackMedia(mediaName: String, mediaCategories: Set<Category>, player: AVPlayer) {
		AVPlayerTracker.track(
			player: player,
			with:   DefaultMediaTracker(handler: self, mediaName: mediaName, mediaCategories: mediaCategories)
		)
	}


	internal func trackView() {
		handler.handleEvent(PageTrackingEvent(advertisementProperties: advertisementProperties, ecommerceProperties: ecommerceProperties, pageProperties: pageProperties, userProperties: userProperties))
	}
}


extension DefaultPageTracker: MediaTrackingEventHandler {

	internal func handleEvent(event: MediaTrackingEvent) {
		var event = event
		if event.pageProperties == nil {
			event.pageProperties = pageProperties
		}
		handler.handleEvent(event)
	}
}