import Foundation
import UIKit


public struct TrackerRequest {

	public var crossDeviceProperties: CrossDeviceProperties
	public var event: TrackingEvent
	public var properties: Properties


	internal init(
		crossDeviceProperties: CrossDeviceProperties,
		event: TrackingEvent,
		properties: Properties
	) {
		self.crossDeviceProperties = crossDeviceProperties
		self.event = event
		self.properties = properties
	}



	public struct Properties {

		public var advertisingId: NSUUID?
		public var advertisingTrackingEnabled: Bool?
		public var appVersion: String?
		public var connectionType: ConnectionType?
		public var everId: String
		public var ipAddress: String?
		public var isFirstEventAfterAppUpdate = false
		public var isFirstEventOfApp = false
		public var isFirstEventOfSession = false
		public var locale: NSLocale?
		public var requestQueueSize: Int?
		public var screenSize: (width: Int, height: Int)?
		public var samplingRate: Int
		public var timeZone: NSTimeZone
		public var timestamp: NSDate
		public var userAgent: String

		#if !os(watchOS)
		public var interfaceOrientation: UIInterfaceOrientation?
		#endif


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
