import XCTest


@testable import Webtrekk


class ParameterTest: XCTestCase {

	func testActionParameter() {
		let actionName = "click"
		let actionParameter = ActionParameter(name:actionName)
		let actionTrackingParameter = ActionTrackingParameter(actionParameter: actionParameter)
		XCTAssertEqual(actionTrackingParameter.actionParameter.name, actionName)
		XCTAssertEqual(actionTrackingParameter.generalParameter.userAgent, "Tracking Library 4.0 (iOS; 9. 3. 0; Simulator; en_US)")
		XCTAssertEqual(actionTrackingParameter.pixelParameter.timeStamp, actionTrackingParameter.generalParameter.timeStamp)
	}


	func testActionParameterWithMore() {
		let actionName = "click"
		var categories = [Int: String]()
		for i in 1...10 {
			categories[i] = "Categorie Parameter \(i)"
		}
		var session = [Int: String]()
		for i in 1...10 {
			session[i] = "Session;Parameter \(i)"
		}
		var products = [ProductParameter]()
		for i in 1...3 {
			var categories = [Int: String]()
			for j in i...7 {
				categories[j] = "Category(\(j))InProduct(\(i))"
			}

			products.append(ProductParameter(categories: categories, currency: i % 2 == 0 ? "" : "EUR", name: "Prodcut\(i)", price: "\(Double(i) * 2.5)", quantity: "\(i)"))
		}
		let actionParameter = ActionParameter(categories: categories, name:actionName, session: session)
		let actionTrackingParameter = ActionTrackingParameter(actionParameter: actionParameter, productParameters: products)
		XCTAssertEqual(actionTrackingParameter.actionParameter.name, actionName)
		XCTAssertEqual(actionTrackingParameter.generalParameter.userAgent, "Tracking Library 4.0 (iOS; 9. 3. 0; Simulator; en_US)")
		XCTAssertEqual(actionTrackingParameter.pixelParameter.timeStamp, actionTrackingParameter.generalParameter.timeStamp)
		print(actionTrackingParameter.urlWithAllParameter(TrackerConfiguration(serverUrl: "http://webtrack.de/tracking", trackingId: "12341231234")))
	}

	func testCustomerParameter() {
		var customerParameter = CustomerParameter()

		// test birthday overwrite as example for all overwrites
		let birthday = "01011970"
		customerParameter.birthday = birthday
		XCTAssert(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: birthday))
		customerParameter.categories = [707: birthday]
		XCTAssert(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: birthday))
		customerParameter.birthday = ""
		XCTAssert(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: birthday))
	}
}

