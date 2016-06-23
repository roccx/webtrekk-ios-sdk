import AVFoundation


public protocol PageTracker: class {

	var advertisementProperties: AdvertisementProperties? { get set }
	var ecommerceProperties: EcommerceProperties? { get set }
	var pageProperties: PageProperties { get set }
	var userProperties: UserProperties? { get set }

	func trackAction (actionName: String)
	func trackAction (actionProperties: ActionProperties)
	func trackMedia  (mediaName: String, player: AVPlayer)
	func trackMedia  (mediaName: String, mediaCategories: Set<Category>, player: AVPlayer) // TODO how to track additional properties?
	func trackView   () // TODO how to track additional properties?
}
