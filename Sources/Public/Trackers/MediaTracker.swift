public protocol MediaTracker: class {

	var advertisementProperties: AdvertisementProperties { get set }
	var customProperties: [String : String] { get set }
	var ecommerceProperties: EcommerceProperties { get set }
	var mediaProperties: MediaProperties { get set }
	var pageProperties: PageProperties { get set }

	func trackAction (action: MediaEvent.Action)
}
