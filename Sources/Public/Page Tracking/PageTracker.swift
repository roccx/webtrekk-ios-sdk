import AVFoundation


public protocol PageTracker: class {

	var pageProperties: PageProperties { get set }

	func trackAction (actionName: String) // TODO how to track additional properties?
	func trackMedia  (mediaName: String, player: AVPlayer)
	func trackMedia  (mediaName: String, mediaCategories: Set<Category>, player: AVPlayer) // TODO how to track additional properties?
	func trackView   () // TODO how to track additional properties?
}
