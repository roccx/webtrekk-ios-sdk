import XCTest


@testable import Webtrekk

private var webtrekk: Webtrekk? = {
	var webtrekk = Webtrekk(config: TrackerConfiguration(sendDelay: 7, serverUrl: "https://q3.webtrekk.net", trackingId: "189053685367929", version: 0))
	webtrekk.enableLoging = true
	return webtrekk
}()


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

extension XCTestCase {

	func writeAndLoad(json: [String: AnyObject]) -> [String: AnyObject]? {
		guard NSJSONSerialization.isValidJSONObject(json) else {
			XCTFail("no valid json")
			return nil
		}
		let prettyPrinted: NSJSONWritingOptions = [] //.PrettyPrinted

		guard let data = try? NSJSONSerialization.dataWithJSONObject(json, options: prettyPrinted) else {
			XCTFail("could not serialize to data")
			return nil
		}

		guard let parsedJson = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject] else {
			return nil
		}

		return parsedJson
	}
}

class ActionParameterBackupTest: XCTestCase {

	let actionName = "click"
	let categoryString = "Category Parameter "
	let sessionString = "Session Parameter "

	lazy var parameter: ActionParameter = ActionParameter(name: self.actionName)

	override func setUp() {
		var categories = [Int: String]()
		for i in 1...10 {
			categories[i] = "\(categoryString)\(i)"
		}
		parameter.categories = categories
		var session = [Int: String]()
		for i in 1...10 {
			session[i] = "\(sessionString)\(i)"
		}
		parameter.session = session
	}

	func testBackup() {
		let json = parameter.toJson()
		guard let parsedJson = writeAndLoad(json) else {
			XCTFail("could not parse json was nil")
			return
		}
		guard let parsedParameter = ActionParameter.fromJson(parsedJson) else {
			XCTFail("could not parse back to parameter")
			return
		}
		XCTAssertEqual(parameter.name, parsedParameter.name)
		XCTAssertEqual(parameter.categories, parsedParameter.categories)
		XCTAssertEqual(parameter.session, parsedParameter.session)
	}
}

class CustomerParameterBackupTest: XCTestCase {

	let birthday = NSDate(timeIntervalSince1970: 183084615) //19751021
	let categoryString = "Category Parameter "
	let city = "Hometown"
	let country = "Homeland"
	let eMail = "son@home.de"
	let eMailReceiverId = "123-123-AB-123"
	let gender = NSDate().timeIntervalSince1970 % 2 < 1 ? CustomerGender.Female : CustomerGender.Male
	let firstName = "Home"
	let lastName = "Guy"
	let newsletter = NSDate().timeIntervalSince1970 % 2 < 1
	let number = "123-456-789-ABC"
	let phoneNumber = "000 112 113 114-02"
	let street = "Homestreet"
	let streetNumber = "21a, App. 2B"
	let zip = "5066A"

	var parameter = CustomerParameter()

	override func setUp() {
		parameter.birthday = birthday
		var categories = [Int: String]()
		for i in 1...10 {
			categories[i] = "\(categoryString)\(i)"
		}
		parameter.categories = categories
		parameter.city = city
		parameter.country = country
		parameter.eMail = eMail
		parameter.eMailReceiverId = eMailReceiverId
		parameter.gender = gender
		parameter.firstName = firstName
		parameter.lastName = lastName
		parameter.newsletter = newsletter
		parameter.number = number
		parameter.phoneNumber = phoneNumber
		parameter.street = street
		parameter.streetNumber = streetNumber
		parameter.zip = zip
	}


	func testBackup() {
		let json = parameter.toJson()
		guard let parsedJson = writeAndLoad(json) else {
			XCTFail("could not parse json was nil")
			return
		}
		guard let parsedParameter = CustomerParameter.fromJson(parsedJson) else {
			XCTFail("could not parse back to parameter")
			return
		}
		XCTAssertEqual(parameter.birthday, parsedParameter.birthday)
		XCTAssertEqual(parameter.categories, parsedParameter.categories)
		XCTAssertEqual(parameter.city, parsedParameter.city)
		XCTAssertEqual(parameter.country, parsedParameter.country)
		XCTAssertEqual(parameter.eMail, parsedParameter.eMail)
		XCTAssertEqual(parameter.eMailReceiverId, parsedParameter.eMailReceiverId)
		XCTAssertEqual(parameter.gender, parsedParameter.gender)
		XCTAssertEqual(parameter.firstName, parsedParameter.firstName)
		XCTAssertEqual(parameter.lastName, parsedParameter.lastName)
		XCTAssertEqual(parameter.newsletter, parsedParameter.newsletter)
		XCTAssertEqual(parameter.number, parsedParameter.number)
		XCTAssertEqual(parameter.phoneNumber, parsedParameter.phoneNumber)
		XCTAssertEqual(parameter.street, parsedParameter.street)
		XCTAssertEqual(parameter.streetNumber, parsedParameter.streetNumber)
		XCTAssertEqual(parameter.zip, parsedParameter.zip)
	}


	func testBackupWithNil() {
		parameter.birthday = nil
		parameter.newsletter = nil
		parameter.gender = nil

		let json = parameter.toJson()
		guard let parsedJson = writeAndLoad(json) else {
			XCTFail("could not parse json was nil")
			return
		}
		guard let parsedParameter = CustomerParameter.fromJson(parsedJson) else {
			XCTFail("could not parse back to parameter")
			return
		}
		XCTAssertEqual(parameter.birthday, parsedParameter.birthday)
		XCTAssertEqual(parameter.categories, parsedParameter.categories)
		XCTAssertEqual(parameter.city, parsedParameter.city)
		XCTAssertEqual(parameter.country, parsedParameter.country)
		XCTAssertEqual(parameter.eMail, parsedParameter.eMail)
		XCTAssertEqual(parameter.eMailReceiverId, parsedParameter.eMailReceiverId)
		XCTAssertEqual(parameter.gender, parsedParameter.gender)
		XCTAssertEqual(parameter.firstName, parsedParameter.firstName)
		XCTAssertEqual(parameter.lastName, parsedParameter.lastName)
		XCTAssertEqual(parameter.newsletter, parsedParameter.newsletter)
		XCTAssertEqual(parameter.number, parsedParameter.number)
		XCTAssertEqual(parameter.phoneNumber, parsedParameter.phoneNumber)
		XCTAssertEqual(parameter.street, parsedParameter.street)
		XCTAssertEqual(parameter.streetNumber, parsedParameter.streetNumber)
		XCTAssertEqual(parameter.zip, parsedParameter.zip)
	}
}

//class EcommerceParameterBackupTest: XCTestCase {
//
//	let actionName = "click"
//	let categoryString = "Category Parameter "
//	let sessionString = "Session Parameter "
//
//	lazy var parameter: ActionParameter = ActionParameter(name: self.actionName)
//
//	override func setUp() {
//		var categories = [Int: String]()
//		for i in 1...10 {
//			categories[i] = "\(categoryString)\(i)"
//		}
//		parameter.categories = categories
//		var session = [Int: String]()
//		for i in 1...10 {
//			session[i] = "\(sessionString)\(i)"
//		}
//		parameter.session = session
//	}
//
//	func testBackup() {
//		let json = parameter.toJson()
//		guard let parsedJson = writeAndLoad(json) else {
//			XCTFail("could not parse json was nil")
//			return
//		}
//		guard let parsedParameter = ActionParameter.fromJson(parsedJson) else {
//			XCTFail("could not parse back to parameter")
//			return
//		}
//		XCTAssertEqual(parameter.name, parsedParameter.name)
//		XCTAssertEqual(parameter.categories, parsedParameter.categories)
//		XCTAssertEqual(parameter.session, parsedParameter.session)
//	}
//}
