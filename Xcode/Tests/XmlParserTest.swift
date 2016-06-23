import XCTest

import Foundation
@testable import Webtrekk

class XmlParserTest: XCTestCase {

	var parser: ConfigParser?

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
		XCTAssertNotNil(parser)
	}

	func testConfigParsing() {
		XCTAssertNotNil(parser?.trackerConfiguration)
	}


	func testMaxRequests() {
		XCTAssertEqual((parser?.trackerConfiguration?.maxRequests)!, 5000)
	}


	func testSamplingRate() {
		XCTAssertEqual((parser?.trackerConfiguration?.samplingRate)!, 0)
	}


	func testSendDelay() {
		XCTAssertEqual((parser?.trackerConfiguration?.sendDelay)!, 300)
	}


	func testVersionParameter() {
		XCTAssertEqual((parser?.trackerConfiguration?.version)!, 1)
	}

	func testAutoTrackingParameters() {
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrack)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackAppUpdate)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackAppVersionName)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackAppVersionCode)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackApiLevel)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackScreenOrientation)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackConnectionType)!)
		XCTAssertTrue((parser?.trackerConfiguration?.autoTrackRequestUrlStoreSize)!)
	}

	func testRemoteConfigurationParameters() {
		XCTAssertFalse((parser?.trackerConfiguration?.enableRemoteConfiguration)!)
		XCTAssertEqual((parser?.trackerConfiguration?.remoteConfigurationUrl)!, "http://remotetrackingconfiguration.info/configfile.xml")
	}
	
}