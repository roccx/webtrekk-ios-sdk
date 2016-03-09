import XCTest


@testable import Webtrekk


class BackupManagerTest: XCTestCase {

	func testEcommerce() {
		var parameter = EcommerceParameter(totalValue: 20.11)
		parameter.details = [1: "help", 2: "not", 3: "me"]
		XCTAssertTrue(NSJSONSerialization.isValidJSONObject(parameter.toJson()))
		if let data = try? ((NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: .PrettyPrinted))) {
			let json = NSString(data: data, encoding: NSUTF8StringEncoding)
			print(json)
			if let para = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) {
				parameter = EcommerceParameter.fromJson(para as! [String : AnyObject])!
				if let data = try? ((NSJSONSerialization.dataWithJSONObject(parameter.toJson(), options: .PrettyPrinted))) {
					let json = NSString(data: data, encoding: NSUTF8StringEncoding)
					print(json)
				}
			}
		}

	}
}