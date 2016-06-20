import Foundation
import UIKit


public struct TrackingEvent {

	public let kind: Kind
	public let properties: Properties


	internal init(kind: Kind, properties: Properties) {
		self.kind = kind
		self.properties = properties
	}



	public enum Kind {

		case media(MediaTrackingEvent)
	}



	public struct Properties {

		public var advertisingId: String?
		public var appVersion: String?
		public var connectionType: ConnectionType?
		public var eventQueueSize: Int?
		public var everId: String
		public var interfaceOrientation: UIInterfaceOrientation?
		public var ipAddress: String?
		public var isAppUpdate: Bool?
		public var isFirstAppStart: Bool?
		public var samplingRate: Int
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

			case other
			case wifi
		}
	}
}
