import Foundation

public protocol GeneralParameter {
	var everId:         String { get set }
	var firstStart:     Bool   { get set }
	var ip:             String { get set }
	var nationalCode:   String { get set }
	var samplingRate:   Int    { get set }
	var timeStamp:      Int64 { get set }
	var timeZoneOffset: Double { get set }
	var userAgent:      String { get set }

}

internal struct DefaultGeneralParameter: GeneralParameter {
	internal var everId:         String
	internal var firstStart:     Bool
	internal var ip:             String
	internal var nationalCode:   String
	internal var samplingRate:   Int
	internal var timeStamp:      Int64
	internal var timeZoneOffset: Double
	internal var userAgent:      String

	internal init(everId:String,  firstStart: Bool = false, ip: String = "", nationalCode: String = "", samplingRate: Int = 0, timeStamp: Int64, timeZoneOffset: Double, userAgent: String){
		guard !everId.isEmpty else {
			fatalError("Ever-Id is not optional")
		}
		self.everId = everId
		self.firstStart = firstStart
		self.ip = ip
		self.nationalCode = nationalCode
		self.samplingRate = samplingRate
		self.timeStamp = timeStamp
		self.timeZoneOffset = timeZoneOffset
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
			queryItems.append(NSURLQueryItem(name: .TimeStamp, value: "\(timeStamp)"))
			queryItems.append(NSURLQueryItem(name: .TimeZoneOffset, value: "\(timeZoneOffsetString())"))
			queryItems.append(NSURLQueryItem(name: .UserAgent, value: userAgent))
			return queryItems.filter({!$0.value!.isEmpty})
		}
	}

	private func timeZoneOffsetString() -> String {
		if timeZoneOffset == 0 || timeZoneOffset - Double(Int(timeZoneOffset)) == 0 {
			return "\(Int(timeZoneOffset))"
		}
		return "\(timeZoneOffset)"
	}
}


