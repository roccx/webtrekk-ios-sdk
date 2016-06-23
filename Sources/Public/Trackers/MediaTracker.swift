public protocol MediaTracker: class {

	var mediaProperties: MediaProperties { get set }

	func trackEvent (kind: MediaTrackingEvent.Kind) // TODO improve naming
}
