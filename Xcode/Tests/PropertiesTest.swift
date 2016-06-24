import XCTest

@testable import Webtrekk


internal class AdvertisementPropertiesTest: XCTestCase {

	internal func test() {
		var advertisementProperties = AdvertisementProperties(id: "wt_mc=1234567")
		advertisementProperties.details = [IndexedProperty(index: 1, value: "Video"), IndexedProperty(index: 2, value: "Bräungungscreme")]
		guard let url = urlFromAdvertisementProperties(advertisementProperties) else {
			return
		}

		XCTAssert(url.absoluteString.decode().containsString("wt_mc=1234567"), "\(url.absoluteString.decode())")

		XCTAssert(url.absoluteString.decode().containsString("Video"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("Bräungungscreme"), "\(url.absoluteString.decode())")
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
			return
		}

		XCTAssert(url.absoluteString.decode().containsString("kl1"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("kl2"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("kl3"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("Tiere"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("Hund & Katze"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("Futter"), "\(url.absoluteString.decode())")

		XCTAssert(url.absoluteString.decode().containsString("llv"), "\(url.absoluteString.decode())")
		XCTAssert(url.absoluteString.decode().containsString("Ungültig"), "\(url.absoluteString.decode())")

	}

	internal func urlFromCustomProperties(customProperties: [String: String]) -> NSURL? {
		var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "page-test"))
		pageViewEvent.customProperties = customProperties
		return urlFromPageViewEvent(pageViewEvent)
	}
}



internal class PagePropertiesTest: XCTestCase {

	internal func testPageName() {
		let pageProperties = PageProperties(name: "page-test")
		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		XCTAssert(url.absoluteString.containsString("page-test"))
	}

	internal func testDetails() {
		var pageProperties = PageProperties(name: "page-test")
		pageProperties.details = [IndexedProperty(index: 1, value: "Schwarz Braun"), IndexedProperty(index: 2, value: "Small")]
		pageProperties.groups = [IndexedProperty(index: 1, value: "Herren"), IndexedProperty(index: 2, value: "Schuhe und Sandalen")]
		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		XCTAssert(url.absoluteString.containsString("Small"))
		XCTAssert(url.absoluteString.decode().containsString("Schwarz Braun"))

		XCTAssert(url.absoluteString.containsString("Herren"))
		XCTAssert(url.absoluteString.decode().containsString("Schuhe und Sandalen"))
	}


	internal func urlFromPageProperties(pageProperties: PageProperties) -> NSURL? {
		return urlFromPageViewEvent(PageViewEvent(pageProperties: pageProperties))
	}
}


private extension XCTestCase {

	private var requestBuilder: RequestUrlBuilder {
		get { return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345") }
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

private extension String {

	private func decode() -> String {
		guard let decoded = self.stringByRemovingPercentEncoding else {
			return self
		}
		return decoded
	}
}