import XCTest

@testable import Webtrekk


internal class ActionPropertiesTest: XCTestCase {
	internal func testPageName() {
		let actionProperties = ActionProperties(name: "action-test")
		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail("Action Name should be enough")
			return
		}

		XCTAssertUrl(url, contains: "ct", with: "action-test")
		XCTAssert(url.absoluteString.containsString("action-test"))
	}

	internal func testDetails() {
		let actionProperties = ActionProperties(name: "action-test", details: [1: "leicht Braun", 2: "Rund"])

		guard let url = urlFromActionProperties(actionProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "ck1", with: "leicht Braun")
		XCTAssertUrl(url, contains: "ck2", with: "Rund")
	}


	internal func urlFromActionProperties(actionProperties: ActionProperties) -> NSURL? {
		return urlForEvent(ActionEvent(actionProperties: actionProperties, pageProperties: PageProperties(name: "page-test")))
	}
}


internal class AdvertisementPropertiesTest: XCTestCase {

	internal func test() {
		var advertisementProperties = AdvertisementProperties(id: "wt_mc=1234567")
		advertisementProperties.details = [1: "Video", 2: "Bräunungscreme"]

		guard let url = urlFromAdvertisementProperties(advertisementProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "cc1", with: "Video")
		XCTAssertUrl(url, contains: "cc2", with: "Bräunungscreme")
		XCTAssertUrl(url, contains: "mc", with: "wt_mc=1234567")
	}


	internal func urlFromAdvertisementProperties(advertisementProperties: AdvertisementProperties) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.advertisementProperties = advertisementProperties
		return urlForEvent(pageViewEvent)
	}

}


internal class EcommercePropertiesTest: XCTestCase {

	internal func test() {
		let ecommerceProperties = EcommerceProperties(currencyCode: "EUR",
		                                              details: [1: "Video", 2: "Rutschmitteltestverfahren XI"],
		                                              orderNumber: "1234-ABCD",
		                                              products: nil,
		                                              status: .viewed,
		                                              totalValue: "10000000",
		                                              voucherValue: "0.01")
		guard let url = urlFromEcommerceProperties(ecommerceProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "cb1", with: "Video")
		XCTAssertUrl(url, contains: "cb2", with: "Rutschmitteltestverfahren XI")
		XCTAssertUrl(url, contains: "cr", with: "EUR")
		XCTAssertUrl(url, contains: "oi", with: "1234-ABCD")
		XCTAssertUrl(url, contains: "st", with: "view")
		XCTAssertUrl(url, contains: "ov", with: "10000000")
		XCTAssertUrl(url, contains: "cb563", with: "0.01")
	}

	internal func urlFromEcommerceProperties(ecommerceProperties: EcommerceProperties) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.ecommerceProperties = ecommerceProperties
		return urlForEvent(pageViewEvent)
	}
}


internal class EcommercePropertiesProductTest: XCTestCase {

	internal func testSingleProduct() {
		var ecommerceProperties = EcommerceProperties()
		ecommerceProperties.products = [EcommerceProperties.Product(name: "Nussmischung",
																	categories: [1: "Schwarz Braun", 2: "Klein"],
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
			EcommerceProperties.Product(name: "Marzipankartoffeln", categories: [1: "Gefüllt"], price: "0.99", quantity: 1),
			EcommerceProperties.Product(name: "Nussmischung", categories: [1: "Schwarz Braun", 2: "Klein"], price: "105.99", quantity: 12),
			EcommerceProperties.Product(name: "Waffeln", categories: [1: "Belgisch", 2: "Karamell", 3: "Glasiert"], price: "35.61", quantity: 6),
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
		return urlForEvent(pageViewEvent)
	}
}


internal class MediaPropertiesTest: XCTestCase {

	internal func testMediaName() {
		let mediaProperties = MediaProperties(name: "media-test")
		guard let url = urlFromMediaProperties(mediaProperties) else {
			XCTFail("Media Name should be enough")
			return
		}

		XCTAssertUrl(url, contains: "mi", with: "media-test")
	}

	internal func testDetails() {
		let mediaProperties = MediaProperties(
			name: "media-test",
			bandwidth: 400000.1,
			duration: NSTimeInterval(3 * 60 + 15),
			groups: [1: "Herren", 2: "Schuhe und Sandalen"],
			position: NSTimeInterval(2 * 60 - 15),
			soundIsMuted: false,
			soundVolume: 0.75)

		guard let url = urlFromMediaProperties(mediaProperties) else {
			XCTFail()
			return
		}

		XCTAssertUrl(url, contains: "mg1", with: "Herren")
		XCTAssertUrl(url, contains: "mg2", with: "Schuhe und Sandalen")
		XCTAssertUrl(url, contains: "mi", with: "media-test")
		XCTAssertUrl(url, contains: "bw", with: "\(Int(400000.1))")
		XCTAssertUrl(url, contains: "mt2", with: "\(3 * 60 + 15)")
		XCTAssertUrl(url, contains: "mt1", with: "\(2 * 60 - 15)")
		XCTAssertUrl(url, contains: "mut", with: "0")
		XCTAssertUrl(url, contains: "vol", with: "75")
		XCTAssertUrl(url, contains: "mk", with: "play")
	}


	internal func urlFromMediaProperties(mediaProperties: MediaProperties) -> NSURL? {
		return urlForEvent(MediaEvent(action: .play, mediaProperties: mediaProperties, pageName: "page-test"))
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
		pageProperties.details = [1: "Schwarz Braun", 2: "Small"]
		pageProperties.groups = [1: "Herren", 2: "Schuhe und Sandalen"]

		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		XCTAssertUrl(url, contains: "cg1", with: "Herren")
		XCTAssertUrl(url, contains: "cg2", with: "Schuhe und Sandalen")
		XCTAssertUrl(url, contains: "cp1", with: "Schwarz Braun")
		XCTAssertUrl(url, contains: "cp2", with: "Small")
	}


	internal func urlFromPageProperties(pageProperties: PageProperties) -> NSURL? {
		return urlForEvent(PageViewEvent(pageProperties: pageProperties))
	}
}


internal class PixelEorPropertiesTest: XCTestCase {

	internal func testPageName() {
		let pageProperties = PageProperties(name: "page-test")
		guard let url = urlForEvent(PageViewEvent(pageProperties: pageProperties)) else {
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


	private func urlForEvent(event: TrackingEvent) -> NSURL? {
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
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


private func XCTAssertUrl(url: NSURL, contains name: String, with value: String, file: StaticString = #file, line: UInt = #line) {
	let queryItems = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)?.queryItems ?? []
	let containsExpectedItem = queryItems.contains(NSURLQueryItem(name: name, value: value))

	XCTAssertTrue(containsExpectedItem, "Expected URL '\(url) to contain query parameter '\(name)' with value '\(value)'.", file: file, line: line)
}
