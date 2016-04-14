import XCTest


@testable import Webtrekk

private var webtrekk: Webtrekk? = {
	var webtrekk = Webtrekk(config: TrackerConfiguration(sendDelay: 7, serverUrl: "https://q3.webtrekk.net", trackingId: "189053685367929", version: 0))
	webtrekk.enableLoging = true
	return webtrekk
}()

private extension XCTest {
	func fillDictonary(range: Range<Int>, contentString: String) -> [Int: String] {
		var dictonary = [Int: String]()
		for index in range {
			dictonary[index] = "\(contentString) \(index)"
		}
		return dictonary
	}


	func dictionaryTest(contentString: String, range: Range<Int>, parameterName: ParameterName, urlPart: String) {
		print(urlPart)
		for index in range {
			XCTAssertTrue(urlPart.containsString("\(contentString) \(index)".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!))
			XCTAssertTrue(urlPart.containsString("\(parameterName.rawValue)\(index)"))
			XCTAssertTrue(urlPart.containsString(ParameterName.urlParameter(fromName: parameterName, withIndex: index, andValue: "\(contentString) \(index)")))
		}
	}


	func testParameter(contentString: String, parameterName: ParameterName, urlPart: String) {
		XCTAssertTrue(urlPart.containsString(contentString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!))
		XCTAssertTrue(urlPart.containsString(parameterName.rawValue))
		XCTAssertTrue(urlPart.containsString(ParameterName.urlParameter(fromName: parameterName, andValue: contentString)))
	}
}



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

			products.append(ProductParameter(categories: categories, currency: i % 2 == 0 ? "" : "EUR", name: "Product\(i)", price: "\(Double(i) * 2.5)", quantity: "\(i)"))
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
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyyMMdd"

		// test birthday overwrite as example for all overwrites
		let birthday = NSDate(timeIntervalSince1970: 183084615) //19751021
		customerParameter.birthday = birthday

		XCTAssert(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))
		customerParameter.categories = [707: "19751021"]
		XCTAssert(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))
		customerParameter.birthday = NSDate()
		XCTAssertFalse(customerParameter.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))
	}

	func testPageParameter() {
		guard let webtrekk = webtrekk else {
			return
		}
		let pageTrackingParameter = PageTrackingParameter(pageName: "TestPage")

		let url = pageTrackingParameter.urlWithAllParameter(webtrekk.config)
		XCTAssertTrue(url.containsString("TestPage"))
		webtrekk.track(pageTrackingParameter)
	}

}

class ActionParameterTest: XCTestCase {

	let actionName = "click"
	lazy var action: ActionParameter = ActionParameter(name: self.actionName)

	override func setUp() {
		action = ActionParameter(name: self.actionName)
	}


	func testActionName() {
		testParameter(actionName, parameterName: .ActionName, urlPart: action.urlParameter)
	}


	func testActionCategories() {
		let categoryString = "Category"
		let range = 1...5
		action.categories = fillDictonary(range, contentString: categoryString)
		dictionaryTest(categoryString, range: range, parameterName: .ActionCategory, urlPart: action.urlParameter)
	}


	func testActionSession(){
		let sessionString = "Session"
		let range = 1...5
		action.session = fillDictonary(range, contentString: sessionString)
		dictionaryTest(sessionString, range: range, parameterName: .Session, urlPart: action.urlParameter)
	}
}


class CustomerParameterTest: XCTestCase {


	var customer: CustomerParameter = CustomerParameter()


	override func setUp() {
		customer = CustomerParameter()
	}


	func testBirthday() {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyyMMdd"

		// test birthday overwrite as example for all overwrites
		let birthday = NSDate(timeIntervalSince1970: 183084615) //19751021
		customer.birthday = birthday
		var urlPart = customer.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "")
		print(urlPart)
		XCTAssert(urlPart == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))

		customer.categories = [707: "19751021"]
		urlPart = customer.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "")
		print(urlPart)
		XCTAssert(customer.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))
		
		customer.birthday = NSDate()
		urlPart = customer.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "")
		print(urlPart)
		XCTAssertFalse(customer.urlParameter.stringByReplacingOccurrencesOfString("&", withString: "") == ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: formatter.stringFromDate(birthday)))
	}


	func testCategories() {
		let categoryString = "Category"
		let range = 1...5
		customer.categories = fillDictonary(range, contentString: categoryString)
		dictionaryTest(categoryString, range: range, parameterName: .CustomerCategory, urlPart: customer.urlParameter)
	}


	func testCity() {
		let content = "City of Mine"
		customer.city = content
		testParameter(content, parameterName: .CustomerCity, urlPart: customer.urlParameter)
	}


	func testCountry() {
		let content = "Country of Mine"
		customer.country = content
		testParameter(content, parameterName: .CustomerCountry, urlPart: customer.urlParameter)
	}


	func testEmail() {
		let content = "email@domain.td"
		customer.eMail = content
		testParameter(content, parameterName: .CustomerEmail, urlPart: customer.urlParameter)
	}


	func testEmailReceiverId() {
		let content = "123-abc-123-abc"
		customer.eMailReceiverId = content
		testParameter(content, parameterName: .CustomerEmailReceiver, urlPart: customer.urlParameter)
	}


	func testGender() {
		let content = NSDate().timeIntervalSince1970 % 2 < 1 ? CustomerGender.Female : CustomerGender.Male // randomize gender based on timestamp
		customer.gender = content
		testParameter("\(content.toValue())", parameterName: .CustomerGender, urlPart: customer.urlParameter)
	}


	func testFirstName() {
		let content = "Gandalf"
		customer.firstName = content
		testParameter(content, parameterName: .CustomerFirstName, urlPart: customer.urlParameter)
	}


	func testLastName() {
		let content = "The Gray"
		customer.lastName = content
		testParameter(content, parameterName: .CustomerLastName, urlPart: customer.urlParameter)
	}


	func testNewsletter() {
		let content = NSDate().timeIntervalSince1970 % 2 < 1 // randomize newsletter based on timestamp
		customer.newsletter = content
		testParameter(content ? "1" : "2", parameterName: .CustomerNewsletter, urlPart: customer.urlParameter)
	}


	func testNumber() {
		let content = "123ABC123-1"
		customer.number = content
		testParameter(content, parameterName: .CustomerNumber, urlPart: customer.urlParameter)
	}


	func testPhoneNumber() {
		let content = "+49 123 123 123-001"
		customer.phoneNumber = content
		testParameter(content, parameterName: .CustomerPhoneNumber, urlPart: customer.urlParameter)
	}


	func testStreet() {
		let content = "Primal Road"
		customer.street = content
		testParameter(content, parameterName: .CustomerStreet, urlPart: customer.urlParameter)
	}


	func testStreetNumber() {
		let content = "204W, Appartment 304F"
		customer.streetNumber = content
		testParameter(content, parameterName: .CustomerStreetNumber, urlPart: customer.urlParameter)
	}


	func testZip() {
		let content = "50667"
		customer.zip = content
		testParameter(content, parameterName: .CustomerZip, urlPart: customer.urlParameter)
	}
}


class EcommerceParameterTest: XCTestCase {

	let totalValue = 20.99
	lazy var ecommerce: EcommerceParameter = EcommerceParameter(totalValue: self.totalValue)


	override func setUp() {
		ecommerce = EcommerceParameter(totalValue: self.totalValue)
	}


	func testCurrency() {
		let content = "CAD"
		ecommerce.currency = content
		testParameter(content, parameterName: .EcomCurrency, urlPart: ecommerce.urlParameter)
	}


	func testCategories() {
		let content = "Category"
		let range = 1...5
		ecommerce.categories = fillDictonary(range, contentString: content)
		dictionaryTest(content, range: range, parameterName: .EcomCategory, urlPart: ecommerce.urlParameter)
	}


	func testOrderNumber() {
		let content = "123-4567-123-AB"
		ecommerce.orderNumber = content
		testParameter(content, parameterName: .EcomOrderNumber, urlPart: ecommerce.urlParameter)
	}


	func testStatus() {
		let content = EcommerceStatus.ADD
		ecommerce.status = content
		testParameter(content.rawValue, parameterName: .EcomStatus, urlPart: ecommerce.urlParameter)
	}


	func testTotalValue() {
		testParameter("\(totalValue)", parameterName: .EcomTotalValue, urlPart: ecommerce.urlParameter)
	}


	func testVoucherValue() {
		let content = 2.15
		ecommerce.voucherValue = content
		testParameter("\(content)", parameterName: .EcomVoucherValue, urlPart: ecommerce.urlParameter)
	}
}


class GeneralParameterTest: XCTestCase {

	let timeStamp = NSDate(timeIntervalSince1970: 183084615) //19751021
	let timeZoneOffset = 0.0
	lazy var general: GeneralParameter = GeneralParameter(timeStamp: self.timeStamp, timeZoneOffset: self.timeZoneOffset)

	override func setUp() {
		general = GeneralParameter(timeStamp: self.timeStamp, timeZoneOffset: self.timeZoneOffset)
	}


	func testEverId() {
		let content = String(format: "6%010.0f%08lu", arguments: [NSDate().timeIntervalSince1970, arc4random_uniform(99999999) + 1])
		XCTAssert(content.characters.count == 19)
		general.everId = content
		testParameter(content, parameterName: .EverId, urlPart: general.urlParameter)
	}


	func testFirstStart() {
		let content = true
		general.firstStart = content
		testParameter("1", parameterName: .FirstStart, urlPart: general.urlParameter)
		general.firstStart = false // false will not add a parameter
		XCTAssertFalse(general.urlParameter.containsString(ParameterName.FirstStart.rawValue))
	}


	func testIp() {
		let content = "10.11.12.13"
		general.ip = content
		testParameter(content, parameterName: .IpAddress, urlPart: general.urlParameter)
	}


	func testNationalCode() {
		let content = NSLocale.currentLocale().localeIdentifier
		general.nationalCode = content
		testParameter(content, parameterName: .NationalCode, urlPart: general.urlParameter)
	}


	func testSamplingRate() {
		testParameter("0", parameterName: .SamplingRate, urlPart: general.urlParameter)
		let content = 15
		general.samplingRate = content
		testParameter("\(content)", parameterName: .SamplingRate, urlPart: general.urlParameter)
	}


	func testTimeStamp() {
		testParameter("183084615000", parameterName: .TimeStamp, urlPart: general.urlParameter)
	}


	func testTimeZoneOffset() {
		testParameter("\(timeZoneOffset)", parameterName: .TimeZoneOffset, urlPart: general.urlParameter)
	}


	func testUserAgent() {
		let content = "Some Random Agent(Version x.x; Language: Corban; Time: Never)"
		general.nationalCode = content
		testParameter(content, parameterName: .NationalCode, urlPart: general.urlParameter)
	}
}


class PageParameterTest: XCTestCase {


	lazy var page: PageParameter = PageParameter()

	override func setUp() {
		page = PageParameter()
	}


	func testPage() {
		let content = "Page"
		let range = 1...5
		page.page = fillDictonary(range, contentString: content)
		dictionaryTest(content, range: range, parameterName: .Page, urlPart: page.urlParameter)
	}


	func testCategories() {
		let content = "Category"
		let range = 1...5
		page.categories = fillDictonary(range, contentString: content)
		dictionaryTest(content, range: range, parameterName: .PageCategory, urlPart: page.urlParameter)
	}


	func testSession() {
		let content = "Session"
		let range = 1...5
		page.session = fillDictonary(range, contentString: content)
		dictionaryTest(content, range: range, parameterName: .Session, urlPart: page.urlParameter)
	}
}


class PixelParameterTest: XCTestCase {

	let displaySize: CGSize = CGSize(width: 1080, height: 1900)
	lazy var pixel: PixelParameter = PixelParameter(displaySize: self.displaySize)

	override func setUp() {
		pixel = PixelParameter(displaySize: self.displaySize)
	}

	func testDisplaySize() { // display size is transfered as Int but saved as CGSize with CGFloats
		let urlPart = pixel.urlParameter
		XCTAssertFalse(urlPart.containsString("\(displaySize.height)"))
		XCTAssertTrue(urlPart.containsString("\(Int(displaySize.height))"))
		XCTAssertFalse(urlPart.containsString("\(displaySize.width)"))
		XCTAssertTrue(urlPart.containsString("\(Int(displaySize.width))"))
		XCTAssertFalse(urlPart.containsString("\(displaySize.width)x\(displaySize.height)"))
		XCTAssertTrue(urlPart.containsString("\(Int(displaySize.width))x\(Int(displaySize.height))"))
	}


	func testPageName() {
		let content = "Main Screen"
		pixel.pageName = content
		XCTAssertFalse(pixel.urlParameter.containsString(content))
		XCTAssertTrue(pixel.urlParameter.containsString(content.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!))
	}


	func testTimeStamp() {
		let date = NSDate(timeIntervalSince1970: 183084615) //19751021
		pixel = PixelParameter(displaySize: displaySize, timeStamp: date)
		XCTAssertTrue(pixel.urlParameter.containsString("\(Int64(date.timeIntervalSince1970 * 1000))"))
		XCTAssertTrue(pixel.urlParameter.containsString("183084615000"))
	}


	func testVersion() {
		XCTAssertTrue(pixel.urlParameter.containsString("400"))
	}
}
