internal protocol TrackingEvent {

	var advertisementProperties: AdvertisementProperties { get mutating set }
	var customProperties: [String : String] { get mutating set }
	var ecommerceProperties: EcommerceProperties { get mutating set }
	var pageProperties: PageProperties { get mutating set }
}
