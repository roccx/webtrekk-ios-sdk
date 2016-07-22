import XCTest

@testable import Webtrekk


class RequestUrlBuilderTest: XCTestCase {

	private let builder = RequestUrlBuilder(serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")
	private let minimalProperties = TrackerRequest.Properties(
		everId:       "Ever&Id",
		samplingRate: 123,
		timeZone:     NSTimeZone(name: "Asia/Kathmandu")!,
		timestamp:    NSDate(timeIntervalSince1970: 1234567890),
		userAgent:    "User&Agent"
	)


	private final func assert(url url: NSURL, doesNotContain name: String, file: StaticString = #file, line: UInt = #line) {
		let queryItems = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)?.queryItems ?? []
		let containsExpectedItem = queryItems.contains { $0.name == name }

		XCTAssertFalse(containsExpectedItem, "Expected URL '\(url) to not contain query parameter '\(name)'.", file: file, line: line)
	}


	private final func assert(url url: NSURL, contains name: String, with value: String, file: StaticString = #file, line: UInt = #line) {
		let queryItems = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)?.queryItems ?? []
		let containsExpectedItem = queryItems.contains(NSURLQueryItem(name: name, value: value))

		XCTAssertTrue(containsExpectedItem, "Expected URL '\(url) to contain query parameter '\(name)' with value '\(value)'.", file: file, line: line)
	}


	private func assert(urlForProperties properties: TrackerRequest.Properties, doesNotContain name: String, file: StaticString = #file, line: UInt = #line) {
		if let url = urlForProperties(properties) {
			assert(url: url, doesNotContain: name, file: file, line: line)
		}
	}


	private func assert(urlForProperties properties: TrackerRequest.Properties, contains name: String, with value: String, file: StaticString = #file, line: UInt = #line) {
		if let url = urlForProperties(properties) {
			assert(url: url, contains: name, with: value, file: file, line: line)
		}
	}


	func testActionProperties() {
		var event = ActionEvent(actionProperties: ActionProperties(name: "?"), pageProperties: PageProperties(name: "?"))

		event.actionProperties = ActionProperties(name: "Action&Name")
		if let url = urlForEvent(event) {
			assert(url: url, contains: "ct", with: "Action&Name")
			assert(url: url, doesNotContain: "ck1")
			assert(url: url, doesNotContain: "ck2")
		}

		event.actionProperties = ActionProperties(name: "Action&Name", details: [1: "Detail&1", 2: "Detail&2"])
		if let url = urlForEvent(event) {
			assert(url: url, contains: "ct", with: "Action&Name")
			assert(url: url, contains: "ck1", with: "Detail&1")
			assert(url: url, contains: "ck2", with: "Detail&2")
		}
	}


	func testAdvertisementProperties() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.advertisementProperties = AdvertisementProperties(id: nil)
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "cc1")
			assert(url: url, doesNotContain: "cc2")
			assert(url: url, doesNotContain: "mc")
			assert(url: url, doesNotContain: "mca")
		}

		event.advertisementProperties = AdvertisementProperties(id: "Advertisement&Id", action: "Action&Name", details: [1: "Detail&1", 2: "Detail&2"])
		if let url = urlForEvent(event) {
			assert(url: url, contains: "cc1", with: "Detail&1")
			assert(url: url, contains: "cc2", with: "Detail&2")
			assert(url: url, contains: "mc",  with: "Advertisement&Id")
			assert(url: url, contains: "mca", with: "Action&Name")
		}
	}


	func testAdvertisingIdProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cs809")

		properties.advertisingId = NSUUID(UUIDString: "00000000-0000-0000-0000-000000000000")
		assert(urlForProperties: properties, contains: "cs809", with: "00000000-0000-0000-0000-000000000000")
	}


	func testAdvertisingTrackingEnabledProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cs813")

		properties.advertisingTrackingEnabled = true
		assert(urlForProperties: properties, contains: "cs813", with: "1")

		properties.advertisingTrackingEnabled = false
		assert(urlForProperties: properties, contains: "cs813", with: "0")
	}


	func testAppVersionProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cs804")

		properties.appVersion = "1.2&3.4 beta"
		assert(urlForProperties: properties, contains: "cs804", with: "1.2&3.4 beta")
	}


	func testConnectionTypeProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cs807")

		let connectionTypes: [TrackerRequest.Properties.ConnectionType : String] = [
			.cellular_2G: "2G",
			.cellular_3G: "3G",
			.cellular_4G: "LTE",
			.offline:     "offline",
			.other:       "unknown",
			.wifi:        "WIFI"
		]

		for (connectionType, value) in connectionTypes {
			properties.connectionType = connectionType
			assert(urlForProperties: properties, contains: "cs807", with: value)
		}
	}


	func testCrossDeviceProperties() {
		let event = PageViewEvent(pageProperties: PageProperties(name: "?"))
		var request = TrackerRequest(crossDeviceProperties: CrossDeviceProperties(), event: event, properties: minimalProperties)

		request.crossDeviceProperties = CrossDeviceProperties()
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "cdb1")
			assert(url: url, doesNotContain: "cdb2")
			assert(url: url, doesNotContain: "cdb3")
			assert(url: url, doesNotContain: "cdb4")
			assert(url: url, doesNotContain: "cdb5")
			assert(url: url, doesNotContain: "cdb6")
			assert(url: url, doesNotContain: "cdb7")
			assert(url: url, doesNotContain: "cdb8")
			assert(url: url, doesNotContain: "cdb9")
			assert(url: url, doesNotContain: "cdb10")
			assert(url: url, doesNotContain: "cdb11")
			assert(url: url, doesNotContain: "cdb12")
			assert(url: url, doesNotContain: "cdb13")
		}

		request.crossDeviceProperties = CrossDeviceProperties(
			address:      .plain(CrossDeviceProperties.Address(
				firstName:    "First&Name _- ÄÖÜäöüß",
				lastName:     "Last&Name _- ÄÖÜäöüß",
				street:       "Street&Name _- ÄÖÜäöüß Str.",
				streetNumber: "Street&Number _- ÄÖÜäöüß",
				zipCode:      "Zip&Code _- ÄÖÜäöüß"
				)),
			androidId:    "Android&Id",
			emailAddress: .plain("Email&Address"),
			facebookId:   "Facebook&Id",
			googlePlusId: "Google&Plus&Id",
			iosId:        "iOS&Id",
			linkedInId:   "LinkedIn&Id",
			phoneNumber:  .plain("+49 221 291-991-60"),
			twitterId:    "Twitter&Id",
			windowsId:    "Windows&Id"
		)
		// Note: address was converted to "first&nameaeoeueaeoeuess|last&nameaeoeueaeoeuess|zip&codeaeoeueaeoeuess|street&nameaeoeueaeoeuessstrasse|street&numberaeoeueaeoeuess"
		if let url = urlForRequest(request) {
			assert(url: url, contains: "cdb1",  with: "9c8ca76f295a39ec6313b41b8887491a")
			assert(url: url, contains: "cdb2",  with: "2c08846d06f903c3c23dae334b6d3f0fe913844ae23fa480d2243c8c84a7caee")
			assert(url: url, contains: "cdb3",  with: "f13c1f1c0959e2636d07622d06c421e1")
			assert(url: url, contains: "cdb4",  with: "b99a4f73937b451674a2e2ad7d4d23c10122e902ad0402dfdf339d7ef1a7a1d0")
			assert(url: url, contains: "cdb5",  with: "356d95817adbae89822f9925b2a4b8c1")
			assert(url: url, contains: "cdb6",  with: "1b169ebeb3cd073222d345e2cd24b99b3008991a549baa63bd04be7a45178f89")
			assert(url: url, contains: "cdb7",  with: "android&id")
			assert(url: url, contains: "cdb8",  with: "ios&id")
			assert(url: url, contains: "cdb9",  with: "windows&id")
			assert(url: url, contains: "cdb10", with: "facebook&id")
			assert(url: url, contains: "cdb11", with: "twitter&id")
			assert(url: url, contains: "cdb12", with: "google&plus&id")
			assert(url: url, contains: "cdb13", with: "linkedin&id")
		}

		request.crossDeviceProperties = CrossDeviceProperties(
			address:      .hashed(md5: "Address&MD5", sha256: "Address&SHA256"),
			emailAddress: .hashed(md5: "Email&Address&MD5", sha256: "Email&Address&SHA256"),
			phoneNumber:  .hashed(md5: "Phone&Number&MD5", sha256: "Phone&Number&SHA256")
		)
		if let url = urlForRequest(request) {
			assert(url: url, contains: "cdb1",  with: "Email&Address&MD5")
			assert(url: url, contains: "cdb2",  with: "Email&Address&SHA256")
			assert(url: url, contains: "cdb3",  with: "Phone&Number&MD5")
			assert(url: url, contains: "cdb4",  with: "Phone&Number&SHA256")
			assert(url: url, contains: "cdb5",  with: "Address&MD5")
			assert(url: url, contains: "cdb6",  with: "Address&SHA256")
		}
	}


	func testCustomVariables() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))
		event.sessionDetails = [
			1: .customVariable(name: "variable1"),
			2: .customVariable(name: "variable2"),
			3: .customVariable(name: "variable3")
		]
		event.variables = [
			"variable1": "Variable&1",
			"variable2": "Variable&2"
		]

		if let url = urlForEvent(event) {
			assert(url: url, contains: "cs1", with: "Variable&1")
			assert(url: url, contains: "cs2", with: "Variable&2")
			assert(url: url, doesNotContain: "cs3")
		}
	}


	func testDefaultVariables() {
		var properties = minimalProperties
		properties.advertisingId = NSUUID(UUIDString: "00000000-0000-0000-0000-000000000000")
		properties.advertisingTrackingEnabled = true
		properties.appVersion = "1.2&3.4 beta"
		properties.connectionType = .wifi
		properties.interfaceOrientation = .Portrait
		properties.isFirstEventAfterAppUpdate = true
		properties.requestQueueSize = 123

		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))
		event.sessionDetails = [
			1: .defaultVariable(.advertisingId),
			2: .defaultVariable(.advertisingTrackingEnabled),
			3: .defaultVariable(.appVersion),
			4: .defaultVariable(.connectionType),
			5: .defaultVariable(.interfaceOrientation),
			6: .defaultVariable(.isFirstEventAfterAppUpdate),
			7: .defaultVariable(.requestQueueSize)
		]

		if let url = urlForRequest(TrackerRequest(crossDeviceProperties: CrossDeviceProperties(), event: event, properties: properties)) {
			assert(url: url, contains: "cs1", with: "00000000-0000-0000-0000-000000000000")
			assert(url: url, contains: "cs2", with: "1")
			assert(url: url, contains: "cs3", with: "1.2&3.4 beta")
			assert(url: url, contains: "cs4", with: "WIFI")
			assert(url: url, contains: "cs5", with: "portrait")
			assert(url: url, contains: "cs6", with: "1")
			assert(url: url, contains: "cs7", with: "123")
		}

		properties.advertisingTrackingEnabled = false
		properties.isFirstEventAfterAppUpdate = false

		if let url = urlForRequest(TrackerRequest(crossDeviceProperties: CrossDeviceProperties(), event: event, properties: properties)) {
			assert(url: url, contains: "cs2", with: "0")
			assert(url: url, contains: "cs6", with: "0")
		}
	}


	func testEcommerceProperties() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.ecommerceProperties = EcommerceProperties()
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "ba")
			assert(url: url, doesNotContain: "ca1")
			assert(url: url, doesNotContain: "ca2")
			assert(url: url, doesNotContain: "cb1")
			assert(url: url, doesNotContain: "cb2")
			assert(url: url, doesNotContain: "co")
			assert(url: url, doesNotContain: "cr")
			assert(url: url, doesNotContain: "oi")
			assert(url: url, doesNotContain: "qn")
			assert(url: url, doesNotContain: "st")
			assert(url: url, doesNotContain: "ov")
			assert(url: url, doesNotContain: "cb563")
		}

		event.ecommerceProperties = EcommerceProperties(
			currencyCode: "EUR",
			details:      [1: "Detail&1", 2: "Detail&2"],
			orderNumber:  "Order&Number",
			products: [
				EcommerceProperties.Product(name: "Product&Name&1", categories: [1: "Category&1&1", 2: "Category&1&2"], price: "Price&1", quantity: 123),
				EcommerceProperties.Product(name: "Product&Name&2", categories: [2: "Category&2&2", 3: "Category&2&3"], price: "Price&2"),
				EcommerceProperties.Product(name: "Product&Name&3", quantity: 456)
			],
			status:       .addedToBasket,
			totalValue:   "Total&Value",
			voucherValue: "Voucher&Value"
		)
		if let url = urlForEvent(event) {
			assert(url: url, contains: "ba",    with: "Product&Name&1;Product&Name&2;Product&Name&3")
			assert(url: url, contains: "ca1",   with: "Category&1&1;;")
			assert(url: url, contains: "ca2",   with: "Category&1&2;Category&2&2;")
			assert(url: url, contains: "cb1",   with: "Detail&1")
			assert(url: url, contains: "cb2",   with: "Detail&2")
			assert(url: url, contains: "co",    with: "Price&1;Price&2;")
			assert(url: url, contains: "cr",    with: "EUR")
			assert(url: url, contains: "oi",    with: "Order&Number")
			assert(url: url, contains: "qn",    with: "123;;456")
			assert(url: url, contains: "st",    with: "add")
			assert(url: url, contains: "ov",    with: "Total&Value")
			assert(url: url, contains: "cb563", with: "Voucher&Value")
		}

		event.ecommerceProperties.status = .purchased
		if let url = urlForEvent(event) {
			assert(url: url, contains: "st", with: "conf")
		}

		event.ecommerceProperties.status = .viewed
		if let url = urlForEvent(event) {
			assert(url: url, contains: "st", with: "view")
		}
	}


	func testInterfaceOrientationProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cp783")

		let interfaceOrientations: [UIInterfaceOrientation : String] = [
			.LandscapeLeft:      "landscape",
			.LandscapeRight:     "landscape",
			.Portrait:           "portrait",
			.PortraitUpsideDown: "portrait",
			.Unknown:            "undefined"
		]

		for (interfaceOrientation, value) in interfaceOrientations {
			properties.interfaceOrientation = interfaceOrientation
			assert(urlForProperties: properties, contains: "cp783", with: value)
		}
	}


	func testIpAddress() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.ipAddress = nil
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "X-WT-IP")
		}

		event.ipAddress = "1.2.3.4"
		if let url = urlForEvent(event) {
			assert(url: url, contains: "X-WT-IP", with: "1.2.3.4")
		}

		event.ipAddress = "2001:0db8:0000:0042:0000:8a2e:0370:7334"
		if let url = urlForEvent(event) {
			assert(url: url, contains: "X-WT-IP", with: "2001:0db8:0000:0042:0000:8a2e:0370:7334")
		}
	}


	func testIsFirstEventAfterAppUpdateProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cs815")

		properties.isFirstEventAfterAppUpdate = true
		assert(urlForProperties: properties, contains: "cs815", with: "1")

		properties.isFirstEventAfterAppUpdate = false
		assert(urlForProperties: properties, doesNotContain: "cs815")
	}


	func testIsFirstEventOfAppProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, contains: "one", with: "0")

		properties.isFirstEventOfApp = true
		assert(urlForProperties: properties, contains: "one", with: "1")

		properties.isFirstEventOfApp = false
		assert(urlForProperties: properties, contains: "one", with: "0")
	}


	func testIsFirstEventOfSessionProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, contains: "fns", with: "0")

		properties.isFirstEventOfSession = true
		assert(urlForProperties: properties, contains: "fns", with: "1")

		properties.isFirstEventOfSession = false
		assert(urlForProperties: properties, contains: "fns", with: "0")
	}


	func testLocaleProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "la")

		properties.locale = NSLocale(localeIdentifier: "de-DE")
		assert(urlForProperties: properties, contains: "la", with: "de")
	}


	func testMediaProperties() {
		var event = MediaEvent(action: .initialize, mediaProperties: MediaProperties(name: "?"), pageName: "?")

		event.mediaProperties = MediaProperties(name: "?")
		if let url = urlForEvent(event) {
			assert(url: url, contains: "mt1", with: "0")
			assert(url: url, contains: "mt2", with: "0")

			assert(url: url, doesNotContain: "bw")
			assert(url: url, doesNotContain: "mg1")
			assert(url: url, doesNotContain: "mg2")
			assert(url: url, doesNotContain: "mut")
			assert(url: url, doesNotContain: "vol")
		}

		event.mediaProperties = MediaProperties(
			name:         "Media&Name",
			bandwidth:    123.456,
			duration:     12345.2,
			groups:       [1: "Group&1", 2: "Group&2"],
			position:     456.7,
			soundIsMuted: true,
			soundVolume:  0.5
		)
		if let url = urlForEvent(event) {
			assert(url: url, contains: "bw",  with: "123")
			assert(url: url, contains: "mg1", with: "Group&1")
			assert(url: url, contains: "mg2", with: "Group&2")
			assert(url: url, contains: "mi",  with: "Media&Name")
			assert(url: url, contains: "mt1", with: "456")
			assert(url: url, contains: "mt2", with: "12345")
			assert(url: url, contains: "mut", with: "1")
			assert(url: url, contains: "vol", with: "50")
		}

		event.mediaProperties.soundIsMuted = false
		if let url = urlForEvent(event) {
			assert(url: url, contains: "mut", with: "0")
		}

		let actions: [(MediaEvent.Action, String)] = [
			(.finish,                      "finish"),
			(.initialize,                  "init"),
			(.pause,                       "pause"),
			(.play,                        "play"),
			(.position,                    "pos"),
			(.seek,                        "seek"),
			(.stop,                        "stop"),
			(.custom(name: "Action&Name"), "Action&Name")
		]

		for (action, value) in actions {
			event.action = action
			if let url = urlForEvent(event) {
				assert(url: url, contains: "mk", with: value)
			}
		}
	}


	func testMinimalProperties() {
		guard let url = urlForProperties(minimalProperties, pageName: "Page&Name") else {
			return
		}

		assert(url: url, contains: "p",       with: "400,Page&Name,0,0x0,32,0,1234567890000,0,0,0")
		assert(url: url, contains: "eid",     with: "Ever&Id")
		assert(url: url, contains: "fns",     with: "0")
		assert(url: url, contains: "mts",     with: "1234567890000")
		assert(url: url, contains: "one",     with: "0")
		assert(url: url, contains: "ps",      with: "123")
		assert(url: url, contains: "tz",      with: "5.75")
		assert(url: url, contains: "X-WT-UA", with: "User&Agent")

		let queryItems = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)?.queryItems ?? []
		XCTAssertEqual(queryItems.first?.name, "p")
		XCTAssertEqual(queryItems.last, NSURLQueryItem(name: "eor", value: "1"))
	}


	func testPageProperties() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.pageProperties = PageProperties(name: "Page&Name")
		if let url = urlForEvent(event) {
			assert(url: url, contains: "p", with: "400,Page&Name,0,0x0,32,0,1234567890000,0,0,0")

			assert(url: url, doesNotContain: "cg1")
			assert(url: url, doesNotContain: "cg2")
			assert(url: url, doesNotContain: "cp1")
			assert(url: url, doesNotContain: "cp2")
			assert(url: url, doesNotContain: "is")
			assert(url: url, doesNotContain: "pu")
		}

		event.pageProperties = PageProperties(name: "Page&Name", details: [1: "Detail&1", 2: "Detail&2"], groups: [1: "Group&1", 2: "Group&2"], internalSearch: "Internal&Search", url: "Page&Url")
		if let url = urlForEvent(event) {
			assert(url: url, contains: "p",   with: "400,Page&Name,0,0x0,32,0,1234567890000,0,0,0")
			assert(url: url, contains: "cg1", with: "Group&1")
			assert(url: url, contains: "cg2", with: "Group&2")
			assert(url: url, contains: "cp1", with: "Detail&1")
			assert(url: url, contains: "cp2", with: "Detail&2")
			assert(url: url, contains: "is", with: "Internal&Search")
			assert(url: url, contains: "pu",  with: "Page&Url")
		}
	}


	func testPixelProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, contains: "p", with: "400,?,0,0x0,32,0,1234567890000,0,0,0")

		properties.screenSize = (640, 960)
		assert(urlForProperties: properties, contains: "p", with: "400,?,0,640x960,32,0,1234567890000,0,0,0")
	}


	func testRequestQueueSizeProperty() {
		var properties = minimalProperties
		assert(urlForProperties: properties, doesNotContain: "cp784")

		properties.requestQueueSize = 123
		assert(urlForProperties: properties, contains: "cp784", with: "123")
	}


	func testSessionDetails() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.sessionDetails = [:]
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "cs1")
			assert(url: url, doesNotContain: "cs2")
		}

		event.sessionDetails = [1: "Detail&1", 2: "Detail&2"]
		if let url = urlForEvent(event) {
			assert(url: url, contains: "cs1", with: "Detail&1")
			assert(url: url, contains: "cs2", with: "Detail&2")
		}
	}


	func testUserProperties() {
		var event = PageViewEvent(pageProperties: PageProperties(name: "?"))

		event.userProperties = UserProperties()
		if let url = urlForEvent(event) {
			assert(url: url, doesNotContain: "cd")
			assert(url: url, doesNotContain: "uc1")
			assert(url: url, doesNotContain: "uc2")
			assert(url: url, doesNotContain: "uc700")
			assert(url: url, doesNotContain: "uc701")
			assert(url: url, doesNotContain: "uc702")
			assert(url: url, doesNotContain: "uc703")
			assert(url: url, doesNotContain: "uc704")
			assert(url: url, doesNotContain: "uc705")
			assert(url: url, doesNotContain: "uc706")
			assert(url: url, doesNotContain: "uc707")
			assert(url: url, doesNotContain: "uc708")
			assert(url: url, doesNotContain: "uc709")
			assert(url: url, doesNotContain: "uc710")
			assert(url: url, doesNotContain: "uc711")
			assert(url: url, doesNotContain: "uc712")
		}

		event.userProperties = UserProperties(
			birthday:             UserProperties.Birthday(day: 11, month: 4, year: 1986),
			city:                 "City&Name",
			country:              "Country&Name",
			details:              [1: "Detail&1", 2: "Detail&2"],
			emailAddress:         "Email&Address",
			emailReceiverId:      "Email&Receiver&Id",
			firstName:            "First&Name",
			gender:               .male,
			id:                   "User&Id",
			lastName:             "Last&Name",
			newsletterSubscribed: true,
			phoneNumber:          "Phone&Number",
			street:               "Street&Name",
			streetNumber:         "Street&Number",
			zipCode:              "Zip&Code"
		)
		if let url = urlForEvent(event) {
			assert(url: url, contains: "cd",    with: "User&Id")
			assert(url: url, contains: "uc1",   with: "Detail&1")
			assert(url: url, contains: "uc2",   with: "Detail&2")
			assert(url: url, contains: "uc700", with: "Email&Address")
			assert(url: url, contains: "uc701", with: "Email&Receiver&Id")
			assert(url: url, contains: "uc702", with: "1") // newsletter subscribed
			assert(url: url, contains: "uc703", with: "First&Name")
			assert(url: url, contains: "uc704", with: "Last&Name")
			assert(url: url, contains: "uc705", with: "Phone&Number")
			assert(url: url, contains: "uc706", with: "1") // gender
			assert(url: url, contains: "uc707", with: "19860411")
			assert(url: url, contains: "uc708", with: "City&Name")
			assert(url: url, contains: "uc709", with: "Country&Name")
			assert(url: url, contains: "uc710", with: "Zip&Code")
			assert(url: url, contains: "uc711", with: "Street&Name")
			assert(url: url, contains: "uc712", with: "Street&Number")
		}

		event.userProperties = UserProperties(
			gender:               .female,
			newsletterSubscribed: false
		)
		if let url = urlForEvent(event) {
			assert(url: url, contains: "uc702", with: "2") // newsletter subscribed
			assert(url: url, contains: "uc706", with: "2") // gender
		}
	}


	private func urlForEvent(event: TrackingEvent) -> NSURL? {
		return urlForRequest(TrackerRequest(crossDeviceProperties: CrossDeviceProperties(), event: event, properties: minimalProperties))
	}


	private func urlForProperties(properties: TrackerRequest.Properties, pageName: String = "?") -> NSURL? {
		let event = PageViewEvent(pageProperties: PageProperties(name: pageName))
		let request = TrackerRequest(crossDeviceProperties: CrossDeviceProperties(), event: event, properties: properties)

		guard let url = builder.urlForRequest(request) else {
			XCTFail("Cannot build URL for request: \(request)")
			return nil
		}

		return url
	}


	private func urlForRequest(request: TrackerRequest) -> NSURL? {
		guard let url = builder.urlForRequest(request) else {
			XCTFail("Cannot build URL for request: \(request)")
			return nil
		}

		return url
	}
}
