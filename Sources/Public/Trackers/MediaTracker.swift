public protocol MediaTracker: class {

	var advertisementProperties: AdvertisementProperties { get set }
	var ecommerceProperties: EcommerceProperties { get set }
	var mediaProperties: MediaProperties { get set }
	var pageProperties: PageProperties { get set }

	func trackEvent (kind: MediaEvent.Kind) // TODO improve naming
}
