import XCTest


@testable import Webtrekk


class HttpClientTest: XCTestCase {

	var client: HttpClient!
	let session = MockUrlSession()

	override func setUp() {
		super.setUp()
		client = HttpClient(session: session)
	}

	func testGetRequest() {
		let url = NSURL(string: "http://www.widgetlabs.eu")!

		client.get(url) { (_,_) -> Void in }
		XCTAssert(session.lastUrl === url)
	}

	func testResumeWasCalled() {
		let dataTask = MockUrlSessionDataTask()
		session.nextDataTask = dataTask

		client.get(NSURL()) { (_,_) -> Void in }
		XCTAssert(dataTask.resumeWasCalled)
	}
}

class HttpClientTest_Integration: XCTestCase {

	var client: HttpClient!

	override func setUp() {
		super.setUp()
		client = HttpClient()
	}

	func testGetRequest() {
		let url = NSURL(string: "http://www.widgetlabs.eu")!
		let expectation = expectationWithDescription("Wait for \(url) to be loaded.")
		var data: NSData?

		client.get(url) { (theData, error) -> Void in
			data = theData
			XCTAssertNil(error)
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(5, handler: nil)
		XCTAssertNotNil(data)

	}
}