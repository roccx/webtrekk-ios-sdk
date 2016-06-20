import Foundation


public final class MediaTracker {

	public var mediaProperties: MediaProperties
	public let parent: Webtrekk


	public init(parent: Webtrekk, mediaId: String, mediaCategories: Set<MediaCategory> = []) {
		self.mediaProperties = MediaProperties(id: mediaId, categories: mediaCategories)
		self.parent = parent
	}


	public func trackEvent(kind: MediaTrackingEvent.Kind) {
		parent.track(MediaTrackingEvent(kind: kind, mediaProperties: mediaProperties))
	}
}
