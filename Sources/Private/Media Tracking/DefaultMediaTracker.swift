internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaTrackingEventHandler

	internal var mediaProperties: MediaProperties


	internal init(handler: MediaTrackingEventHandler, mediaName: String, mediaCategories: Set<Category>) {
		self.handler = handler
		self.mediaProperties = MediaProperties(name: mediaName, categories: mediaCategories)
	}


	internal func trackEvent(kind: MediaTrackingEvent.Kind) {
		handler.handleEvent(MediaTrackingEvent(kind: kind, mediaProperties: mediaProperties))
	}
}
