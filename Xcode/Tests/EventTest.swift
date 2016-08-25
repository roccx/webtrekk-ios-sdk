//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widget Labs
//

import XCTest

@testable import Webtrekk

internal class ActionEventTest: XCTestCase {

	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testActionEvent() {
		let actionProperties = ActionProperties(name: "action-test")
		let pageProperties = PageProperties(name: "page-test")
		let event = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
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
		let event = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}


	internal func testActionEventEmptyPageName() {
		let actionProperties = ActionProperties(name: "")
		let pageProperties = PageProperties(name: "")
		let event = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}


internal class MediaEventTest: XCTestCase {

	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testMediaEvent() {
		let mediaProperties = MediaProperties(name: "media-test")
		let event = MediaEvent(action: .play, mediaProperties: mediaProperties, pageName: "page-test")
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
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
		let event = MediaEvent(action: .play, mediaProperties: mediaProperties, pageName: "page-test")
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}


	internal func testMediaEventEmptyPageName() {
		let mediaProperties = MediaProperties(name: "")
		let event = MediaEvent(action: .play, mediaProperties: mediaProperties, pageName: "")
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}


internal class PageViewEventTest: XCTestCase {
	internal var requestBuilder: RequestUrlBuilder = {
		return RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	}()


	internal func testPageViewEvent() {
		let pageProperties = PageProperties(name: "page-test")
		let event = PageViewEvent(pageProperties: pageProperties)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)
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
		let event = PageViewEvent(pageProperties: pageProperties)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties)

		XCTAssertNil(requestBuilder.urlForRequest(request))
	}
}
