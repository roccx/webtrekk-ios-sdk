import XCTest

@testable import Webtrekk


internal class ActionEventTest: XCTestCase {

	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testActionEvent() {
		let actionProperties = ActionProperties(name: "action-test")
		let pageProperties = PageProperties(name: "page-test")
		let actionEvent = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.action(actionEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		let url = requestBuilder.urlForRequest(request)
		XCTAssertNotNil(url, "Page Name needs to be set for a valid Event")
		guard let urlString = url?.absoluteString else {
			XCTFail("NSURL could not return absolute string for the Url '\(url)'")
			return
		}
		XCTAssert(urlString.containsString("action-test"))
		XCTAssert(urlString.containsString("page-test"))
	}


	internal func testActionEventEmptyActionName() {
		let actionProperties = ActionProperties(name: "")
		let pageProperties = PageProperties(name: "page-test")
		let actionEvent = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.action(actionEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}


	internal func testActionEventEmptyPageName() {
		let actionProperties = ActionProperties(name: "")
		let pageProperties = PageProperties(name: "")
		let actionEvent = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.action(actionEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}


internal class MediaEventTest: XCTestCase {

	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testMediaEvent() {
		let mediaProperties = MediaProperties(name: "media-test")
		let pageProperties = PageProperties(name: "page-test")
		let mediaEvent = MediaEvent(action: .play, mediaProperties: mediaProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.media(mediaEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		let url = requestBuilder.urlForRequest(request)
		XCTAssertNotNil(url, "Page Name needs to be set for a valid Event")
		guard let urlString = url?.absoluteString else {
			XCTFail("NSURL could not return absolute string for the Url '\(url)'")
			return
		}
		XCTAssert(urlString.containsString("media-test"))
		XCTAssert(urlString.containsString("page-test"))
	}


	internal func testMediaEventEmptyMediaName() {
		let mediaProperties = MediaProperties(name: "")
		let pageProperties = PageProperties(name: "page-test")
		let mediaEvent = MediaEvent(action: .play, mediaProperties: mediaProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.media(mediaEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}


	internal func testMediaEventEmptyPageName() {
		let mediaProperties = MediaProperties(name: "")
		let pageProperties = PageProperties(name: "")
		let mediaEvent = MediaEvent(action: .play, mediaProperties: mediaProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.media(mediaEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}


internal class PageViewEventTest: XCTestCase {
	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testPageViewEvent() {
		let pageProperties = PageProperties(name: "page-test")
		let pageViewEvent = PageViewEvent(pageProperties: pageProperties)
		let event = TrackerRequest.Event.pageView(pageViewEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		let url = requestBuilder.urlForRequest(request)
		XCTAssertNotNil(url, "Page Name needs to be set for a valid Event")
		guard let urlString = url?.absoluteString else {
			XCTFail("NSURL could not return absolute string for the Url '\(url)'")
			return
		}

		XCTAssert(urlString.containsString("page-test"))
	}


	internal func testPageViewEventEmptyPageName() {
		let pageProperties = PageProperties(name: "")
		let pageViewEvent = PageViewEvent(pageProperties: pageProperties)
		let event = TrackerRequest.Event.pageView(pageViewEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)

		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}