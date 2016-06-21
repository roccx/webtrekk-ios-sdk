import AVFoundation


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = protocol<ActionTrackingEventHandler, MediaTrackingEventHandler, PageTrackingEventHandler>

	private let handler: Handler
	
	internal var pageProperties: PageProperties


	internal init(handler: Handler, pageName: String) {
		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal func trackAction(actionName: String) {
		handler.handleEvent(ActionTrackingEvent(actionProperties: ActionProperties(name: actionName)))
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
		handler.handleEvent(PageTrackingEvent(pageProperties: pageProperties))
	}
}


extension DefaultPageTracker: MediaTrackingEventHandler {

	internal func handleEvent(event: MediaTrackingEvent) {
		var event = event
		event.pageProperties = pageProperties
		handler.handleEvent(event)
	}
}
