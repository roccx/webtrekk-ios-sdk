import Foundation


public struct GeneralParameter {
	public var everId:         String
	public var firstStart:     Bool
	public var ip:             String
	public var nationalCode:   String
	public var samplingRate:   Int
	public var timeStamp:      Int64
	public var timeZoneOffset: Double
	public var userAgent:      String

	public init(everId:String,  firstStart: Bool = false, ip: String = "", nationalCode: String = "", samplingRate: Int = 0, timeStamp: Int64, timeZoneOffset: Double, userAgent: String){
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
			var urlParameter = "\(ParameterName.EverId.rawValue)=\(everId)"
			if firstStart {
				urlParameter += "&\(ParameterName.FirstStart.rawValue)=1"
			}
			if !ip.isEmpty {
				urlParameter += "&\(ParameterName.IpAddress.rawValue)=\(ip)"
			}
			if !nationalCode.isEmpty {
				urlParameter += "&\(ParameterName.NationalCode.rawValue)=\(nationalCode)"
			}
			urlParameter += "&\(ParameterName.SamplingRate.rawValue)=\(samplingRate)"
			urlParameter += "&\(ParameterName.TimeStamp.rawValue)=\(timeStamp)"
			urlParameter += "&\(ParameterName.TimeZoneOffset.rawValue)=\(timeZoneOffset)"
			urlParameter += "&\(ParameterName.UserAgent.rawValue)=\(userAgent.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"

			return urlParameter
		}
	}
}


extension GeneralParameter {
	internal init(timeStamp: Int64, timeZoneOffset: Double){
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