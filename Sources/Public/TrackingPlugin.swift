public protocol TrackingPlugin: class {

	func tracker (tracker: Webtrekk, requestForQueuingRequest request: TrackingRequest) -> TrackingRequest
	func tracker (tracker: Webtrekk, didQueueRequest request: TrackingRequest)
}
