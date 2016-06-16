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