import XCTest

@testable import Webtrekk



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
		pageProperties.details = [IndexedProperty(index: 1, value: "kritisch")]
		guard let url = urlFromPageProperties(pageProperties) else {
			XCTFail("Page Name should be enough")
			return
		}

		XCTAssert(url.absoluteString.containsString("kritisch"))
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