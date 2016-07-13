public protocol TrackingEventWithCustomProperties: TrackingEvent {

	var customProperties: [String : String] { get mutating set }
}
