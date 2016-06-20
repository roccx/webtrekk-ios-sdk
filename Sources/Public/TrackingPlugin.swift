public protocol TrackingPlugin: class {

	func tracker (tracker: Webtrekk, eventForTrackingEvent event: TrackingEvent) -> TrackingEvent
	func tracker (tracker: Webtrekk, didTrackEvent event: TrackingEvent)
}
