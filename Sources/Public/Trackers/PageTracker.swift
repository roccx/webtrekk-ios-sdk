import AVFoundation


public protocol PageTracker: class {

	var advertisementProperties: AdvertisementProperties { get set }
	var ecommerceProperties: EcommerceProperties { get set }
	var pageProperties: PageProperties { get set }

	func trackAction     (name name: String)
	func trackAction     (properties properties: ActionProperties)
	func trackPageView   ()
	func trackerForMedia (name name: String, player: AVPlayer)
	func trackerForMedia (name name: String, categories: Set<Category>?, player: AVPlayer) // TODO how to track additional properties?
}
