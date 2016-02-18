import Foundation

public protocol GeneralParameter {
	var everId:         String { get }
	var firstStart:     Bool   { get }
	var ip:             String { get }
	var nationalCode:   String { get }
	var samplingRate:   Int    { get }
	var timestamp:      Int    { get }
	var timezoneOffset: Double { get }
	var userAgent:      String { get }

}

internal struct DefaultGeneralParameter: GeneralParameter {
	internal let everId:         String
	internal let firstStart:     Bool
	internal let ip:             String
	internal let nationalCode:   String
	internal let samplingRate:   Int
	internal let timestamp:      Int
	internal let timezoneOffset: Double
	internal let userAgent:      String

	internal init(everId:String,  firstStart: Bool = false, ip: String = "", nationalCode: String = "", samplingRate: Int = 0, timestamp: Int, timezoneOffset: Double, userAgent: String){
		guard !everId.isEmpty else {
			fatalError("Ever-Id is not optional")
		}
		self.everId = everId
		self.firstStart = firstStart
		self.ip = ip
		self.nationalCode = nationalCode
		self.samplingRate = samplingRate
		self.timestamp = timestamp
		self.timezoneOffset = timezoneOffset
		self.userAgent = userAgent
	}
}

extension DefaultGeneralParameter: Parameter {

	internal var queryItems: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()

			guard !everId.isEmpty else {
				fatalError("everId should never be empty")
			}
			queryItems.append(NSURLQueryItem(name: .EverId, value: everId))

			queryItems.append(NSURLQueryItem(name: .FirstStart, value: firstStart ? "1" : ""))
			queryItems.append(NSURLQueryItem(name: .NationalCode, value: nationalCode))
			queryItems.append(NSURLQueryItem(name: .SamplingRate, value: "\(samplingRate)"))
			queryItems.append(NSURLQueryItem(name: .TimeStamp, value: "\(timestamp)"))
			queryItems.append(NSURLQueryItem(name: .TimeZoneOffset, value: "\(timeZoneOffsetString())"))
			queryItems.append(NSURLQueryItem(name: .UserAgent, value: userAgent))
			return queryItems.filter({!$0.value!.isEmpty})
		}
	}

	private func timeZoneOffsetString() -> String {
		if timezoneOffset == 0 || timezoneOffset - Double(Int(timezoneOffset)) == 0 {
			return "\(Int(timezoneOffset))"
		}
		return "\(timezoneOffset)"
	}
}


