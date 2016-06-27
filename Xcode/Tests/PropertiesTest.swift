import XCTest

@testable import Webtrekk


internal class ActionPropertiesTest: XCTestCase {
	internal func testPageName() {
		let actionProperties = ActionProperties(name: "action-test")
		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail("Action Name should be enough")
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "ct", value: "action-test"))

		XCTAssert(url.absoluteString.containsString("action-test"))
	}

	internal func testDetails() {
		let actionProperties = ActionProperties(name: "action-test", details: [IndexedProperty(index: 1, value: "leicht Braun"), IndexedProperty(index: 2, value: "Rund")])
		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail()
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		for detail in actionProperties.details! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: detail, name: "ck")
		}

	}


	internal func urlFromActionProperties(actionProperties: ActionProperties) -> NSURL? {
		return urlFromActionEvent(ActionEvent(actionProperties: actionProperties, pageProperties: PageProperties(name: "page-test")))
	}
	
}


internal class AdvertisementPropertiesTest: XCTestCase {

	internal func test() {
		var advertisementProperties = AdvertisementProperties(id: "wt_mc=1234567")
		advertisementProperties.details = [IndexedProperty(index: 1, value: "Video"), IndexedProperty(index: 2, value: "Bräunungscreme")]
		guard let url = urlFromAdvertisementProperties(advertisementProperties) else {
			XCTFail()
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mc", value: "wt_mc=1234567"))

		for detail in advertisementProperties.details! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: detail, name: "cc")
		}
	}


	internal func urlFromAdvertisementProperties(advertisementProperties: AdvertisementProperties) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.advertisementProperties = advertisementProperties
		return urlFromPageViewEvent(pageViewEvent)
	}

}


internal class CustomProperties: XCTestCase {

	internal func test() {
		let customProperties = ["kl1": "Tiere", "kl2": "Hund & Katze", "kl3": "Futter", "llv": "Ungültig"]
		guard let url = urlFromCustomProperties(customProperties) else {
			XCTFail()
			return
		}
		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		for detail in customProperties {
			XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: detail.0, value: detail.1))
		}
	}

	internal func urlFromCustomProperties(customProperties: [String: String]) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.customProperties = customProperties
		return urlFromPageViewEvent(pageViewEvent)
	}
}


internal class EcommercePropertiesTest: XCTestCase {

	internal func test() {
		let ecommerceProperties = EcommerceProperties(currencyCode: "EUR",
		                                              details: [IndexedProperty(index: 1, value: "Video"), IndexedProperty(index: 2, value: "Rutschmitteltestverfahren XI")],
		                                              orderNumber: "1234-ABCD",
		                                              products: nil,
		                                              status: .viewed,
		                                              totalValue: "10000000",
		                                              voucherValue: "0.01")
		guard let url = urlFromEcommerceProperties(ecommerceProperties) else {
			XCTFail()
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "cr", value: "EUR"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "oi", value: "1234-ABCD"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "st", value: "view"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "ov", value: "10000000"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "cb563", value: "0.01"))
		
		for detail in ecommerceProperties.details! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: detail, name: "cb")
		}
	}

	internal func urlFromEcommerceProperties(ecommerceProperties: EcommerceProperties) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.ecommerceProperties = ecommerceProperties
		return urlFromPageViewEvent(pageViewEvent)
	}
}


internal class EcommercePropertiesProductTest: XCTestCase {

	internal func testSingleProduct() {
		var ecommerceProperties = EcommerceProperties()
		ecommerceProperties.products = [EcommerceProperties.Product(name: "Nussmischung",
																	categories: [IndexedProperty(index: 1, value: "Schwarz Braun"), IndexedProperty(index: 2, value: "Klein")],
																	price: "105.99",
																	quantity: 12)]
		guard let url = urlFromEcommerceProperties(ecommerceProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "Nussmischung")
		XCTAssertUrl(url, contains: "Schwarz Braun")
		XCTAssertUrl(url, contains: "Klein")
		XCTAssertUrl(url, contains: "105.99")
		XCTAssertUrl(url, contains: "12")
	}


	internal func testMultiProduct() {
		var ecommerceProperties = EcommerceProperties()
		ecommerceProperties.products = [
			EcommerceProperties.Product(name: "Marzipankartoffeln", categories: [IndexedProperty(index: 1, value: "Gefüllt")], price: "0.99", quantity: 1),
			EcommerceProperties.Product(name: "Nussmischung", categories: [IndexedProperty(index: 1, value: "Schwarz Braun"), IndexedProperty(index: 2, value: "Klein")], price: "105.99", quantity: 12),
			EcommerceProperties.Product(name: "Waffeln", categories: [IndexedProperty(index: 1, value: "Belgisch"), IndexedProperty(index: 2, value: "Karamell"), IndexedProperty(index: 3, value: "Glasiert")], price: "35.61", quantity: 6),
		]
		guard let url = urlFromEcommerceProperties(ecommerceProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "Nussmischung")
		XCTAssertUrl(url, contains: "Schwarz Braun")
		XCTAssertUrl(url, contains: "Klein")
		XCTAssertUrl(url, contains: "105.99")
		XCTAssertUrl(url, contains: "12")
	}


	internal func urlFromEcommerceProperties(ecommerceProperties: EcommerceProperties) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.ecommerceProperties = ecommerceProperties
		return urlFromPageViewEvent(pageViewEvent)
	}
}


internal class MediaPropertiesTest: XCTestCase {

	internal func testMediaName() {
		let mediaProperties = MediaProperties(name: "media-test")
		guard let url = urlFromMediaProperties(mediaProperties) else {
			XCTFail("Media Name should be enough")
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mi", value: "media-test"))
	}

	internal func testDetails() {
		let mediaProperties = MediaProperties(
			name: "media-test",
			bandwidth: 400000.1,
			duration: NSTimeInterval(3 * 60 + 15),
			groups: [IndexedProperty(index: 1, value: "Herren"), IndexedProperty(index: 2, value: "Schuhe und Sandalen")],
			position: NSTimeInterval(2 * 60 - 15),
			soundIsMuted: false,
			soundVolume: 0.75)

		guard let url = urlFromMediaProperties(mediaProperties) else {
			XCTFail()
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mi", value: "media-test"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "bw", value: "\(Int(400000.1))"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mt2", value: "\(3 * 60 + 15)"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mt1", value: "\(2 * 60 - 15)"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mut", value: "0"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "vol", value: "75"))
		XCTAssertUrl(urlComponents, containsQueryItem: NSURLQueryItem(name: "mk", value: "play"))

		for group in mediaProperties.groups! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: group, name: "mg")
		}
	}


	internal func urlFromMediaProperties(mediaProperties: MediaProperties) -> NSURL? {
		return urlFromMediaEvent(MediaEvent(action: .play, mediaProperties: mediaProperties, pageProperties: PageProperties(name: "page-test")))
	}
}


internal class PagePropertiesTest: XCTestCase {

	internal func testPageName() {
		let pageProperties = PageProperties(name: "page-test")
		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		XCTAssertUrl(url, contains: "page-test")
	}

	internal func testDetails() {
		var pageProperties = PageProperties(name: "page-test")
		pageProperties.details = [IndexedProperty(index: 1, value: "Schwarz Braun"), IndexedProperty(index: 2, value: "Small")]
		pageProperties.groups = [IndexedProperty(index: 1, value: "Herren"), IndexedProperty(index: 2, value: "Schuhe und Sandalen")]
		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else{
			XCTFail("Could not convert '\(url)' to NSURLComponents.")
			return
		}

		for detail in pageProperties.details! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: detail, name: "cp")
		}

		for group in pageProperties.groups! {
			XCTAssertUrl(urlComponents, containsIndexedProperty: group, name: "cg")
		}
	}


	internal func urlFromPageProperties(pageProperties: PageProperties) -> NSURL? {
		return urlFromPageViewEvent(PageViewEvent(pageProperties: pageProperties))
	}
}


internal class PixelEorPropertiesTest: XCTestCase {

	internal func testPageName() {
		let pageProperties = PageProperties(name: "page-test")
		guard let url = urlFromPageViewEvent(PageViewEvent(pageProperties: pageProperties)) else {
			XCTFail()
			return
		}

		guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else {
			XCTFail()
			return
		}
		let parameters = urlComponents.queryItems
		guard let pixelName = parameters?.first?.name else {
			XCTFail("should always have parameters")
			return
		}
		XCTAssertEqual(pixelName, "p")
		guard let eorName = parameters?.last?.name else {
			XCTFail("should always have parameters")
			return
		}

		XCTAssertEqual(eorName, "eor")
	}
}

private extension XCTestCase {

	private var requestBuilder: RequestUrlBuilder {
		get { return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345") }
	}


	private func urlFromActionEvent(actionEvent: ActionEvent) -> NSURL? {
		let event = TrackerRequest.Event.action(actionEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		return requestBuilder.urlForRequest(request)
	}


	private func urlFromMediaEvent(mediaEvent: MediaEvent) -> NSURL? {
		let event = TrackerRequest.Event.media(mediaEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		return requestBuilder.urlForRequest(request)
	}


	private func urlFromPageViewEvent(pageViewEvent: PageViewEvent) -> NSURL? {
		let event = TrackerRequest.Event.pageView(pageViewEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		return requestBuilder.urlForRequest(request)
	}
}

private func XCTAssertUrl(url: NSURL, contains value: String) {
	guard let decoded = url.absoluteString.stringByRemovingPercentEncoding else {
		XCTAssertTrue(url.absoluteString.containsString(value))
		return
	}
	XCTAssertTrue(decoded.containsString(value))
}

private func XCTAssertUrl(url: NSURLComponents, containsQueryItem queryItem: NSURLQueryItem) {
	guard let queryItems = url.queryItems else {
		XCTFail("The '\(url)' has no query Items to compare against.")
		return
	}
	for item in queryItems where item.name == queryItem.name && item.value == queryItem.value {
		XCTAssertTrue(true)
		return
	}
	XCTFail("Could not find a NSURLQueryItem with name:'\(queryItem.name)' and value:'\(queryItem.value)' within '\(url)'")
}

private func XCTAssertUrl(url: NSURLComponents, containsIndexedProperty property: IndexedProperty, name: String) {
	XCTAssertUrl(url, containsQueryItem: NSURLQueryItem(name: "\(name)\(property.index)", value: property.value))
}
