import XCTest


@testable import Webtrekk


class WebtrekkTests: XCTestCase {

	private var webtrekk: Webtrekk? = {
		var webtrekk = Webtrekk(config: TrackerConfiguration(autoTrack: true, appVersion: "1.1F", samplingRate: 1, sendDelay: 7, serverUrl: "https://q3.webtrekk.net/", trackingId: "1111111111111", version: 5))
		webtrekk.enableLoging = true

		return webtrekk
	}()
}

class WebtrekkTest: XCTestCase {


}

class ActionTest: WebtrekkTests {

	lazy var actionParameter: ActionParameter = ActionParameter(name: "click")
	lazy var actionTracking: ActionTracking = ActionTracking(actionParameter: self.actionParameter)
	let pageName = "click-test"

	override func setUp() {
		actionParameter = ActionParameter(name: "click-test")
		webtrekk?.track(pageName)
	}

	override func tearDown() {
		webtrekk?.flush = true
		let expectation = expectationWithDescription("wait for sending")
		delay(1) {
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(2, handler: nil)
		XCTAssertFalse(webtrekk!.flush)
	}


	func testAction() throws {
		actionTracking = ActionTracking(actionParameter: self.actionParameter)
		webtrekk?.track(pageName, trackingParameter: actionTracking)
	}


	func testActionWithCategories() throws {
		for i in 1...10 {
			actionParameter.categories[i] = "Category Parameter \(i)"
		}
		actionTracking = ActionTracking(actionParameter: self.actionParameter)
		webtrekk?.track(pageName, trackingParameter: actionTracking)
	}


	func testActionWithSession() throws {
		for i in 1...10 {
			actionParameter.session[i] = "Session Parameter \(i)"
		}
		actionTracking = ActionTracking(actionParameter: self.actionParameter)
		webtrekk?.track(pageName, trackingParameter: actionTracking)
	}


	func testActionWithProduct() throws {
		actionTracking = ActionTracking(actionParameter: self.actionParameter)
		for i in 1...10 {
			actionTracking.productParameters.append(ProductParameter(name: "Product \(i)"))
		}
		webtrekk?.track(pageName, trackingParameter: actionTracking)
	}


	func testActionWithCustom() throws {
		actionTracking = ActionTracking(actionParameter: self.actionParameter)
		for i in 1...10 {
			actionTracking.customParameters["cpi\(i)"] = "Custom Parameter \(i)"
		}
		webtrekk?.track(pageName, trackingParameter: actionTracking)
	}
}

class PageTest: WebtrekkTests {

	let pageName = "page-test"

	override func tearDown() {
		webtrekk?.flush = true
		let expectation = expectationWithDescription("wait for sending")
		delay(1) {
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(2, handler: nil)
		XCTAssertFalse(webtrekk!.flush)
	}

	func testPage() throws {
		webtrekk?.track(pageName)
	}

	func testPageByName() throws {
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName))
	}

	func testPageWithPage() throws {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.page[i] = "Page Parameter \(i)"
		}
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName, pageParameter: pageParameter))
	}

	func testPageWithPageCategories() throws {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.categories[i] = "Category Parameter \(i)"
		}
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName, pageParameter: pageParameter))
	}


	func testPageWithPageSession() throws {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.session[i] = "Session Parameter \(i)"
		}
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName, pageParameter: pageParameter))
	}


	func testPageWithProduct() throws {
		var pageTracking = PageTracking(pageName: pageName)
		for i in 1...10 {
			pageTracking.productParameters.append(ProductParameter(name: "Product \(i)"))
		}
		webtrekk?.track(pageName, trackingParameter: pageTracking)
	}


	func testPageWithCustom() throws {
		var pageTracking = PageTracking(pageName: "page-test")
		for i in 1...10 {
			pageTracking.customParameters["cpi\(i)"] = "Custom Parameter \(i)"
		}
		webtrekk?.track(pageName, trackingParameter: pageTracking)
	}


	func testPageWithEcommerce() throws {
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName, ecommerceParameter: EcommerceParameter(totalValue: 10)))
	}


	func testPageWithEcommerceAdd() throws {
		var ecommerceParameter = EcommerceParameter(status: .ADD, totalValue: 10)
		for i in 1...10 {
			ecommerceParameter.categories[i] = "Category Parameter \(i)"
		}
		ecommerceParameter.currency = "EUR"
		ecommerceParameter.orderNumber = "10231230234 - 0001"
		ecommerceParameter.voucherValue = 5.12
		webtrekk?.track(pageName, trackingParameter: PageTracking(pageName: pageName, ecommerceParameter: ecommerceParameter))
	}
}