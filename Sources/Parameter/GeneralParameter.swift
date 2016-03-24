import Foundation


public struct GeneralParameter {
	public var everId:         String
	public var firstStart:     Bool
	public var ip:             String
	public var nationalCode:   String
	public var samplingRate:   Int
	public var timeStamp:      NSDate
	public var timeZoneOffset: Double
	public var userAgent:      String

	public init(everId:String,  firstStart: Bool = false, ip: String = "", nationalCode: String = "", samplingRate: Int = 0, timeStamp: NSDate, timeZoneOffset: Double, userAgent: String){
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

extension GeneralParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = "&\(ParameterName.urlParameter(fromName: .EverId, andValue: everId))"
			if firstStart {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .FirstStart, andValue: "1"))"
			}
			if !ip.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .IpAddress, andValue: ip))"
			}
			if !nationalCode.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .NationalCode, andValue: nationalCode))"
			}
			urlParameter += "&\(ParameterName.urlParameter(fromName: .SamplingRate, andValue: "\(samplingRate)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .TimeStamp, andValue: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .TimeZoneOffset, andValue: "\(timeZoneOffset)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .UserAgent, andValue: userAgent))"

			return urlParameter
		}
	}
}


extension GeneralParameter {
	internal init(timeStamp: NSDate, timeZoneOffset: Double){
		self.everId = ""
		self.firstStart = false
		self.ip = ""
		self.nationalCode = ""
		self.samplingRate = 0
		self.timeStamp = timeStamp
		self.timeZoneOffset = timeZoneOffset
		self.userAgent = ""
	}
}