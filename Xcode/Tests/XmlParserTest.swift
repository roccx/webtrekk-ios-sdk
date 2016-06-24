import XCTest

import Foundation
@testable import Webtrekk

class XmlParserTest: XCTestCase {

	internal var configurationData: NSData = {
		guard let configurationFile = NSBundle(forClass: XmlParserTest.self).URLForResource("DefaultConfig", withExtension: "xml") else {
			fatalError("Cannot locate DefaultConfig.xml")
		}
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)'")
		}
		return configurationData
	}()


	func testParserInit() {
		do {
			try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
	}
}