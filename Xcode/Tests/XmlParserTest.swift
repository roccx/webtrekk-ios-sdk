import XCTest

import Foundation
@testable import Webtrekk


internal class XmlParserAutomaticTest: XCTestCase {

	internal var configurationData: NSData = {
		guard let configurationFile = NSBundle(forClass: XmlParserManualTest.self).URLForResource("ConfigAutomatic", withExtension: "xml") else {
			fatalError("Cannot locate ConfigAutomatic.xml")
		}
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)'")
		}
		return configurationData
	}()


	internal func testParserInit() {
		do {
			try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
	}

	internal func testParserConfig() {
		let config: TrackerConfiguration
		do {
			config = try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
		XCTAssertEqual(config.maximumSendDelay, 30)
		XCTAssertEqual(config.requestQueueLimit, 5000)
		XCTAssertEqual(config.samplingRate, 0)
		XCTAssertEqual(config.serverUrl.absoluteString, "https://q3.webtrekk.net")
		XCTAssertEqual(config.sessionTimeoutInterval, 1800)
		XCTAssertEqual(config.version, 1)
		XCTAssertEqual(config.webtrekkId, "289053685367929")
		XCTAssertNotNil(config.configurationUpdateUrl)
		if let url = config.configurationUpdateUrl {
			XCTAssertEqual(url.absoluteString, "https://your.domain/webtrekk.xml")
		}
		XCTAssertEqual(config.automaticallyTracksAdvertisingId, true)
		XCTAssertEqual(config.automaticallyTracksAppUpdates, true)
		XCTAssertEqual(config.automaticallyTracksAppVersion, true)
		XCTAssertEqual(config.automaticallyTracksConnectionType, true)
		XCTAssertEqual(config.automaticallyTracksInterfaceOrientation, true)
		XCTAssertEqual(config.automaticallyTracksRequestQueueSize, true)

		XCTAssertFalse(config.automaticallyTrackedPages.isEmpty)

		for (index, page) in config.automaticallyTrackedPages.enumerate() {
			XCTAssertNotNil(page.pageProperties.name)
			guard index == 1 else {
				continue
			}
			if let details = page.pageProperties.details {
				XCTAssertTrue(details.count == 2)
			}
			if let groups = page.pageProperties.groups {
				XCTAssertTrue(groups.count == 1)
			}
		}
	}
}


internal class XmlParserManualTest: XCTestCase {

	internal var configurationData: NSData = {
		guard let configurationFile = NSBundle(forClass: XmlParserManualTest.self).URLForResource("ConfigManual", withExtension: "xml") else {
			fatalError("Cannot locate ConfigManual.xml")
		}
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)'")
		}
		return configurationData
	}()


	internal func testParserInit() {
		do {
			try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
	}

	internal func testParserConfig() {
		let config: TrackerConfiguration
		do {
			config = try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
		XCTAssertEqual(config.maximumSendDelay, 30)
		XCTAssertEqual(config.requestQueueLimit, 5000)
		XCTAssertEqual(config.samplingRate, 0)
		XCTAssertEqual(config.serverUrl.absoluteString, "https://q3.webtrekk.net")
		XCTAssertEqual(config.sessionTimeoutInterval, 1800)
		XCTAssertEqual(config.version, 1)
		XCTAssertEqual(config.webtrekkId, "289053685367929")
		XCTAssertNil(config.configurationUpdateUrl)
		XCTAssert(config.automaticallyTrackedPages.isEmpty)
		XCTAssertEqual(config.automaticallyTracksAdvertisingId, false)
		XCTAssertEqual(config.automaticallyTracksAppUpdates, false)
		XCTAssertEqual(config.automaticallyTracksAppVersion, false)
		XCTAssertEqual(config.automaticallyTracksConnectionType, false)
		XCTAssertEqual(config.automaticallyTracksInterfaceOrientation, false)
		XCTAssertEqual(config.automaticallyTracksRequestQueueSize, false)
	}
}


internal class XmlParserMinimalTest: XCTestCase {

	internal var configurationData: NSData = {
		guard let configurationFile = NSBundle(forClass: XmlParserManualTest.self).URLForResource("ConfigMinimal", withExtension: "xml") else {
			fatalError("Cannot locate ConfigMinimal.xml")
		}
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)'")
		}
		return configurationData
	}()


	internal func testParserInit() {
		do {
			try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
	}

	internal func testParserConfig() {
		let config: TrackerConfiguration
		do {
			config = try XmlTrackerConfigurationParser().parse(xml: configurationData)
		}
		catch let error {
			fatalError("Cannot Read Webtrekk configuration: \(error)")
		}
		XCTAssertEqual(config.maximumSendDelay, 5 * 60)
		XCTAssertEqual(config.requestQueueLimit, 1000)
		XCTAssertEqual(config.samplingRate, 0)
		XCTAssertEqual(config.serverUrl.absoluteString, "https://q3.webtrekk.net")
		XCTAssertEqual(config.sessionTimeoutInterval, 30 * 60)
		XCTAssertEqual(config.version, 1)
		XCTAssertEqual(config.webtrekkId, "289053685367929")
		XCTAssertNil(config.configurationUpdateUrl)
		XCTAssert(config.automaticallyTrackedPages.isEmpty)
		XCTAssertEqual(config.automaticallyTracksAdvertisingId, true)
		XCTAssertEqual(config.automaticallyTracksAppUpdates, true)
		XCTAssertEqual(config.automaticallyTracksAppVersion, true)
		XCTAssertEqual(config.automaticallyTracksConnectionType, true)
		XCTAssertEqual(config.automaticallyTracksInterfaceOrientation, true)
		XCTAssertEqual(config.automaticallyTracksRequestQueueSize, true)
	}
}