import XCTest

import Foundation
@testable import Webtrekk


internal class ActionEventTest: XCTestCase {

	internal func testActionEvent() {
		let actionProperties = ActionProperties(name: "")
		let pageProperties = PageProperties(name: "")
		let actionEvent = ActionEvent(actionProperties: actionProperties, pageProperties: pageProperties)
		let event = TrackerRequest.Event.action(actionEvent)
		let crossDeviceProperites = CrossDeviceProperties()
		let trackerRequestProperties = TrackerRequest.Properties(everId: "", samplingRate: 1, timeZone: NSTimeZone.defaultTimeZone(), timestamp: NSDate(), userAgent: "")
		let userProperties = UserProperties()
		let request = TrackerRequest(crossDeviceProperties: crossDeviceProperites, event: event, properties: trackerRequestProperties, userProperties: userProperties)
		UrlCreator.createUrlFromEvent(request, serverUrl: NSURL(string: "https://test.domain/wt")!, webtrekkId: "123456789012345")

	}
}
