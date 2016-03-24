import XCTest


@testable import Webtrekk


class BackupManagerTest: XCTestCase {

	let prettyPrinted: NSJSONWritingOptions = [] //.PrettyPrinted

	func testEcommerce() {
		var parameter = EcommerceParameter(totalValue: 20.11)
		parameter.categories = [1: "help", 2: "not", 3: "me"]
		XCTAssertTrue(NSJSONSerialization.isValidJSONObject(parameter.toJson()))
		if let data = try? ((NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: prettyPrinted))) {
			let json = NSString(data: data, encoding: NSUTF8StringEncoding)
			print(json)
			if let para = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) {
				parameter = EcommerceParameter.fromJson(para as! [String : AnyObject])!
				if let data = try? ((NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: prettyPrinted))) {
					let json = NSString(data: data, encoding: NSUTF8StringEncoding)
					print(json)
				}
			}
		}
	}

	func testActionTrackingParameter() {
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
		var parameter = ActionTrackingParameter(actionParameter: actionParameter, productParameters: products)
		XCTAssertTrue(NSJSONSerialization.isValidJSONObject(parameter.toJson()))
		if let data = try? NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: prettyPrinted) {
			let json = NSString(data: data, encoding: NSUTF8StringEncoding)
			print(json)
			if let para = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) {
				parameter = ActionTrackingParameter.fromJson(para as! [String : AnyObject])!
				if let data = try? ((NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: prettyPrinted))) {
					let json = NSString(data: data, encoding: NSUTF8StringEncoding)
					print(json)
				}
			}
		}
	}
}