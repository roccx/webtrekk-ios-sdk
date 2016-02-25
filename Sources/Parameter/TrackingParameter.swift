import UIKit


public protocol TrackingParameter {
	var ecommerceParameter: EcommerceParameter? { get set }
	var generalParameter:   GeneralParameter   { get }
	var pixelParameter:     PixelParameter     { get }
	var productParameters:  [ProductParameter] { get set }
}

extension TrackingParameter {

	public var everId: String {
		get {
			let userDefaults = NSUserDefaults.standardUserDefaults()
			if let eid = userDefaults.stringForKey("eid") {
				return eid
			}
			let eid = String(format: "6%010.0f%08lu", arguments: [NSDate().timeIntervalSince1970, arc4random_uniform(99999999) + 1])
			userDefaults.setValue(eid, forKey:"eid")
			return eid
		}
		set {
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setValue(newValue, forKey:"eid")
		}
	}


	public var userAgent: String {
		get {
			let os = NSProcessInfo().operatingSystemVersion
			return "Tracking Library \(Double(pixelParameter.version/100)) (iOS; \(os.majorVersion). \(os.minorVersion). \(os.patchVersion); \(UIDevice.currentDevice().modelName); \(NSLocale.currentLocale().localeIdentifier))"
		}
	}
}

public protocol ActionTrackingParameter: TrackingParameter {
	var actionParameter: ActionParameter { get set }
}

public protocol PageTrackingParameter: TrackingParameter {
	var pageParameter: PageParameter { get set }
}

internal struct DefaultActionTrackingParameter: ActionTrackingParameter{
	internal var actionParameter:    ActionParameter
	internal var ecommerceParameter: EcommerceParameter?
	internal var generalParameter:   GeneralParameter
	internal var pixelParameter:     PixelParameter
	internal var productParameters:  [ProductParameter]


	internal init(actionParameter: ActionParameter, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = [ProductParameter]()) {

		let timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.actionParameter = actionParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = DefaultGeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}

}

internal struct DefaultPageTrackingParameter: PageTrackingParameter{
	internal var pageParameter:      PageParameter
	internal var ecommerceParameter: EcommerceParameter?
	internal var generalParameter:   GeneralParameter
	internal var pixelParameter:     PixelParameter
	internal var productParameters:  [ProductParameter]

	internal init(pageParameter: PageParameter, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = [ProductParameter]()) {

		let timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.pageParameter = pageParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = DefaultGeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}
}

extension DefaultGeneralParameter {
	private init(timeStamp: Int64, timeZoneOffset: Double){
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