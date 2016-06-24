import XCTest

import Foundation
@testable import Webtrekk

class XmlParserTest: XCTestCase {

	internal var fileData: NSData? {

	}

	override func setUp() {
		guard let url = NSBundle(forClass: XmlParserTest.self).URLForResource("DefaultConfig", withExtension: "xml"), let xmlString = try? String(contentsOfURL: url) else {
			fatalError("config file url not possible")
		}
		do {
			parser = try XmlConfigParser(xmlString: xmlString)
		} catch {
			fatalError("config file not parsable")
		}
	}

	func testParserInit() {
		try XmlTrackerConfigurationParser().parse(xml: configurationData)
	}
}