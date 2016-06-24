import XCTest

@testable import Webtrekk


internal class ActionPropertiesTest: XCTestCase {
	internal func testPageName() {
		let actionProperties = ActionProperties(name: "action-test")
		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail("Action Name should be enough")
			return
		}

		XCTAssert(url.absoluteString.containsString("action-test"))
	}

	internal func testDetails() {
		let actionProperties = ActionProperties(name: "action-test", details: [IndexedProperty(index: 1, value: "leicht Braun"), IndexedProperty(index: 2, value: "Rund")])
		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "Rund")
		XCTAssertUrl(url, contains: "leicht Braun")

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

		XCTAssertUrl(url, contains: "wt_mc=1234567")

		XCTAssertUrl(url, contains: "Video")
		XCTAssertUrl(url, contains: "Bräunungscreme")
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

		XCTAssertUrl(url, contains: "kl1")
		XCTAssertUrl(url, contains: "kl2")
		XCTAssertUrl(url, contains: "kl3")
		XCTAssertUrl(url, contains: "Tiere")
		XCTAssertUrl(url, contains: "Hund & Katze")
		XCTAssertUrl(url, contains: "Futter")

		XCTAssertUrl(url, contains: "llv")
		XCTAssertUrl(url, contains: "Ungültig")

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
		                                              products: nil,
		                                              status: .viewed,
		                                              totalValue: "10000000",
		                                              voucherValue: "0.01")
		guard let url = urlFromEcommerceProperties(ecommerceProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "EUR")
		XCTAssertUrl(url, contains: "view")
		XCTAssertUrl(url, contains: "10000000")
		XCTAssertUrl(url, contains: "0.01")
		XCTAssertUrl(url, contains: "Video")
		XCTAssertUrl(url, contains: "Rutschmitteltestverfahren XI")
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

		XCTAssertUrl(url, contains: "media-test")
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

		XCTAssertUrl(url, contains: "\(400000.1)")
		XCTAssertUrl(url, contains: "\(3 * 60 + 15)")
		XCTAssertUrl(url, contains: "Herren")
		XCTAssertUrl(url, contains: "Schuhe und Sandalen")
		XCTAssertUrl(url, contains: "\(2 * 60 - 15)")
		XCTAssertUrl(url, contains: "mut=0")
		XCTAssertUrl(url, contains: "\(75)")
	}


	internal func urlFromMediaProperties(mediaProperties: MediaProperties) -> NSURL? {
		return urlFromMediaEvent(MediaEvent(kind: .play, mediaProperties: mediaProperties, pageProperties: PageProperties(name: "page-test")))
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

		XCTAssertUrl(url, contains: "Small")
		XCTAssertUrl(url, contains: "Schwarz Braun")

		XCTAssertUrl(url, contains: "Herren")
		XCTAssertUrl(url, contains: "Schuhe und Sandalen")
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

private func XCTAssertUrl(url: NSURL, contains value: String) -> Bool {
	guard let decoded = url.absoluteString.stringByRemovingPercentEncoding else {
		return url.absoluteString.containsString(value)
	}
	return decoded.containsString(value)
}