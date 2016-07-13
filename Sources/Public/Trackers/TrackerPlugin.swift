/**
The `TrackerPlugin` gets invoked regardless the OptOut state right before the `TrackerRequest` is enqueued for delivery and can edit the request before.

After the `TrackerRequest` should have been enqueued the `TrackerPlugin` gets another chances to handle the request.

As the `TrackerPlugin` is always called it is for the plugin to keep track of the OptOut state which can be obtained like this
```
let isOptOut = WebtrekkTracking.isOptedOuts
```
*/
public protocol TrackerPlugin: class {

	/** Handle the `TrackerRequest` before it is enqueued for delivery. */
	func tracker (tracker: Tracker, requestForQueuingRequest request: TrackerRequest) -> TrackerRequest
	/** Handle the `TrackerRequest` after it was enqueued. */
	func tracker (tracker: Tracker, didQueueRequest request: TrackerRequest)
}