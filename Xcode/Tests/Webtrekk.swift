import XCTest


@testable import Webtrekk


class WebtrekkTests: XCTestCase {

	private var webtrekk: Webtrekk? = {
		var webtrekk = Webtrekk(config: TrackerConfiguration(autoTrack: true,appVersion: "1.1F", samplingRate: 1, sendDelay: 7, serverUrl: "https://q3.webtrekk.net/", trackingId: "1111111111111", version: 5))
		webtrekk.enableLoging = true

		return webtrekk
	}()
}

class ActionTest: WebtrekkTests {

	lazy var actionParameter: ActionParameter = ActionParameter(name: "click")
	lazy var actionTrackingParameter: ActionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)


	override func setUp() {
		actionParameter = ActionParameter(name: "click-test")
		webtrekk?.track(PageTrackingParameter(pageName: "prepare-click-test"))
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


	func testAction() {
		actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
		webtrekk?.track(actionTrackingParameter)
	}


	func testActionWithCategories() {
		for i in 1...10 {
			actionParameter.categories[i] = "Category Parameter \(i)"
		}
		actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
		webtrekk?.track(actionTrackingParameter)
	}


	func testActionWithSession() {
		for i in 1...10 {
			actionParameter.session[i] = "Session Parameter \(i)"
		}
		actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
		webtrekk?.track(actionTrackingParameter)
	}


	func testActionWithProduct() {
		actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
		for i in 1...10 {
			actionTrackingParameter.productParameters.append(ProductParameter(name: "Product \(i)"))
		}
		webtrekk?.track(actionTrackingParameter)
	}


	func testActionWithCustom() {
		actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
		for i in 1...10 {
			actionTrackingParameter.customParameters["cpi\(i)"] = "Custom Parameter \(i)"
		}
		webtrekk?.track(actionTrackingParameter)
	}
}

class PageTest: WebtrekkTests {


	override func tearDown() {
		webtrekk?.flush = true
		let expectation = expectationWithDescription("wait for sending")
		delay(1) {
			expectation.fulfill()
		}
		waitForExpectationsWithTimeout(2, handler: nil)
		XCTAssertFalse(webtrekk!.flush)
	}

	func testPage() {
		webtrekk?.track(PageTrackingParameter())
	}

	func testPageByName() {
		webtrekk?.track(PageTrackingParameter(pageName: "page-test"))
	}

	func testPageWithPage() {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.page[i] = "Page Parameter \(i)"
		}
		webtrekk?.track(PageTrackingParameter(pageName: "page-test", pageParameter: pageParameter))
	}

	func testPageWithPageCategories() {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.categories[i] = "Category Parameter \(i)"
		}
		webtrekk?.track(PageTrackingParameter(pageName: "page-test", pageParameter: pageParameter))
	}


	func testPageWithPageSession() {
		var pageParameter = PageParameter()
		for i in 1...10 {
			pageParameter.session[i] = "Session Parameter \(i)"
		}
		webtrekk?.track(PageTrackingParameter(pageName: "page-test", pageParameter: pageParameter))
	}


	func testPageWithProduct() {
		var pageTrackingParameter = PageTrackingParameter(pageName: "page-test")
		for i in 1...10 {
			pageTrackingParameter.productParameters.append(ProductParameter(name: "Product \(i)"))
		}
		webtrekk?.track(pageTrackingParameter)
	}


	func testPageWithCustom() {
		var pageTrackingParameter = PageTrackingParameter(pageName: "page-test")
		for i in 1...10 {
			pageTrackingParameter.customParameters["cpi\(i)"] = "Custom Parameter \(i)"
		}
		webtrekk?.track(pageTrackingParameter)
	}


	func testPageWithEcommerce() {
		webtrekk?.track(PageTrackingParameter(ecommerceParameter: EcommerceParameter(totalValue: 10) ,pageName: "page-test"))
	}


	func testPageWithEcommerceAdd() {
		var ecommerceParameter = EcommerceParameter(status: .ADD, totalValue: 10)
		for i in 1...10 {
			ecommerceParameter.categories[i] = "Category Parameter \(i)"
		}
		ecommerceParameter.currency = "EUR"
		ecommerceParameter.orderNumber = "10231230234 - 0001"
		ecommerceParameter.voucherValue = 5.12
		webtrekk?.track(PageTrackingParameter(ecommerceParameter: ecommerceParameter ,pageName: "page-test"))
	}
}