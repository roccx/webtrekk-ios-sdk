public protocol TrackerPlugin: class {

	func tracker (tracker: Tracker, requestForQueuingRequest request: TrackerRequest) -> TrackerRequest
	func tracker (tracker: Tracker, didQueueRequest request: TrackerRequest)
}
