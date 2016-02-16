import XCTest

import Foundation
import SWXMLHash
@testable import Webtrekk

class XmlParserTest: XCTestCase {

	var parser: ConfigParser?

	override func setUp() {
		parser = XmlConfigParser(xmlString: "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<webtrekkConfiguration>\r\n\t<!--the version number for this configuration file -->\r\n\t<version>1</version>\r\n\t<!--the webtrekk trackDomain where the requests are send -->\r\n\t<trackDomain>http://defaulttrackingdomain.info</trackDomain>\r\n\t<!--customers trackid -->\r\n\t<trackId>1234567890ABCDEFGH</trackId>\r\n\t<!-- measure only a subset of the users -->\r\n\t<sampling>0</sampling>\r\n\t<!-- interval between the requests are send in seconds -->\r\n\t<sendDelay>300</sendDelay>\r\n\t<!--maximum amoount of requests to store when the user is offline -->\r\n\t<maxRequests>5000</maxRequests>\r\n\r\n\t<!--optional settings -->\r\n\t<!--automaticly track activities onStart method -->\r\n\t<autoTracked>true</autoTracked>\r\n\r\n\t<!--track if there was an application update -->\r\n\t<autoTrackAppUpdate>true</autoTrackAppUpdate>\r\n\t<!--track the advertiser id -->\r\n\t<autoTrackAdvertiserId>true</autoTrackAdvertiserId>\r\n\r\n\t<!--track the app versions name -->\r\n\t<autoTrackAppVersionName>true</autoTrackAppVersionName>\r\n\t<!--track the app versions code -->\r\n\t<autoTrackAppVersionCode>true</autoTrackAppVersionCode>\r\n\r\n\t<!--track the supported api level of the device, requires special permissions! -->\r\n\t<autoTrackApiLevel>true</autoTrackApiLevel>\r\n\r\n\t<!--track the devices screen orientation -->\r\n\t<autoTrackScreenOrientation>true</autoTrackScreenOrientation>\r\n\r\n\t<!--track the current connection type -->\r\n\t<autoTrackConnectionType>true</autoTrackConnectionType>\r\n\r\n\t<!--sends the size of the current locally stored urls in a custom parameter -->\r\n\t<autoTrackRequestUrlStoreSize>true</autoTrackRequestUrlStoreSize>\r\n\r\n\t<!--enables the remote xml configuration -->\r\n\t<enableRemoteConfiguration>false</enableRemoteConfiguration>\r\n\t<!--url of the remote configuration -->\r\n\t<trackingConfigurationUrl>http://remotetrackingconfiguration.info/configfile.xml</trackingConfigurationUrl>\r\n\r\n\t<!--resend onStart time, this is the timeout for auto tracked sessions in case an activity was paused -->\r\n\t<resendOnStartEventTime>30</resendOnStartEventTime>\r\n\r\n</webtrekkConfiguration>")

	}

	func testParserInit() {
		XCTAssertNotNil(parser)
	}

	func testConfigParsing() {
		XCTAssertNotNil(parser?.trackerConfiguration)
	}


	func testMaxRequests() {
		XCTAssertEqual((parser?.trackerConfiguration.maxRequests)!, 5000)
	}


	func testSamplingRate() {
		XCTAssertEqual((parser?.trackerConfiguration.samplingRate)!, 0)
	}


	func testSendDelay() {
		XCTAssertEqual((parser?.trackerConfiguration.sendDelay)!, 300)
	}


	func testVersionParameter() {
		XCTAssertEqual((parser?.trackerConfiguration.version)!, 1)
	}
	
}