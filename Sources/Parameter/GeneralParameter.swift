import Foundation

public struct GeneralParameter {
	public let everId: String
	public let firstStart: Bool
	public let nationalCode: String
	public let samplingRate: Int
	public let timestamp: Int
	public let timezoneOffset: Double
	public let userAgent: String

	public init(everId:String,  firstStart: Bool = false, nationalCode: String = "", samplingRate: Int = 0, timestamp: Int, timezoneOffset: Double, userAgent: String){
		guard !everId.isEmpty else {
			fatalError("Ever-Id is not optional")
		}
		self.everId = everId
		self.nationalCode = nationalCode
		self.timestamp = timestamp
		self.firstStart = firstStart
		self.samplingRate = samplingRate
		self.timezoneOffset = timezoneOffset
		self.userAgent = userAgent
	}
}

extension GeneralParameter: Parameter {

	public var queryItems: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()

			guard !everId.isEmpty else {
				fatalError("everId should never be empty")
			}
			queryItems.append(NSURLQueryItem(name: .EVER_ID, value: everId))

			queryItems.append(NSURLQueryItem(name: .FIRST_START, value: firstStart ? "1" : ""))
			queryItems.append(NSURLQueryItem(name: .NATIONAL_CODE, value: nationalCode))
			queryItems.append(NSURLQueryItem(name: .SAMPLING_RATE, value: "\(samplingRate)"))
			queryItems.append(NSURLQueryItem(name: .TIMESTAMP, value: "\(timestamp)"))
			queryItems.append(NSURLQueryItem(name: .TIIMEZONE_OFFSET, value: "\(timeZoneOffsetString())"))
			queryItems.append(NSURLQueryItem(name: .USER_AGENT, value: userAgent))
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


