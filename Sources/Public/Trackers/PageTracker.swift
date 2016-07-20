#if !os(watchOS)
	import AVFoundation
#endif


public protocol PageTracker: class {

	var advertisementProperties: AdvertisementProperties { get set }
	var ecommerceProperties: EcommerceProperties { get set }
	var pageProperties: PageProperties { get set }
	var variables: [String : String] { get set }


	func trackAction(actionName: String)

	func trackAction(event: ActionEvent)

	func trackMedia(event: MediaEvent)

	func trackPageView()

	@warn_unused_result
	func trackerForMedia(mediaName: String) -> MediaTracker

	#if !os(watchOS)
	func trackerForMedia(mediaName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker
	#endif
}


public extension PageTracker {

	public func trackAction(actionName: String) {
		trackAction(ActionEvent(actionProperties: ActionProperties(name: actionName), pageProperties: pageProperties))
	}
}
