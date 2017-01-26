//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//


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

		public var advertisingId: UUID?
		public var advertisingTrackingEnabled: Bool?
		public var appVersion: String?
		public var connectionType: ConnectionType?
		public var everId: String
		public var isFirstEventAfterAppUpdate = false
		public var isFirstEventOfApp = false
		public var isFirstEventOfSession = false
		public var locale: Locale?
		public var requestQueueSize: Int?
		public var screenSize: (width: Int, height: Int)?
		public var samplingRate: Int
		public var timeZone: TimeZone
		public var timestamp: Date
		public var userAgent: String
        public var adClearId: UInt64?

		#if !os(watchOS) && !os(tvOS)
		public var interfaceOrientation: UIInterfaceOrientation?
		#endif


		internal init(
			everId: String,
			samplingRate: Int,
			timeZone: TimeZone,
			timestamp: Date,
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
