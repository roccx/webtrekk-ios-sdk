import Foundation
import UIKit


public struct TrackingEvent {

	public let kind: Kind
	public let properties: Properties
	public var userProperties: UserProperties?


	internal init(kind: Kind, properties: Properties) {
		self.kind = kind
		self.properties = properties
	}



	public enum Kind {

		case action(ActionEvent)
		case media(MediaEvent)
		case pageView(PageViewEvent)
	}



	public struct Properties {

		public var advertisingId: NSUUID?
		public var appVersion: String?
		public var connectionType: ConnectionType?
		public var eventQueueSize: Int?
		public var everId: String
		public var forceNewSesson: Bool?
		public var interfaceOrientation: UIInterfaceOrientation?
		public var ipAddress: String?
		public var isAppUpdate: Bool?
		public var isFirstAppStart: Bool?
		public var samplingRate: Int
		public var sessionCategories: Set<Category>?
		public var timeZone: NSTimeZone
		public var timestamp: NSDate
		public var userAgent: String


		internal init(
			everId: String,
			samplingRate: Int,
			timeZone: NSTimeZone,
			timestamp: NSDate,
			userAgent: String
		) {
			self.everId = everId
			self.samplingRate = samplingRate
			self.timeZone = timeZone
			self.timestamp = timestamp
			self.userAgent = userAgent
		}



		public enum ConnectionType {

			case cellular_2G
			case cellular_3G
			case cellular_4G
			case offline
			case other
			case wifi
		}
	}
}
