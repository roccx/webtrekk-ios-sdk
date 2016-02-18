import UIKit

public struct TrackingParameter {
	public var customer: Customer?
	public var product: Product?

	private let os = NSProcessInfo().operatingSystemVersion
	private let device = UIDevice.currentDevice().modelName
	private let language = NSLocale.currentLocale().localeIdentifier
	private var pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size)

	private var parameters = [Parameter]()

	private var buildUserAgent: String {
		get {
			return "Tracking Library \(Double(pixelParameter.version/100)) (iOS; \(os.majorVersion + os.minorVersion + os.patchVersion); \(UIDevice.currentDevice().modelName); \(language))"
		}
	}

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

	public var pageName: String {
		get {
			return pixelParameter.pageName
		}
		set {
			guard newValue != pixelParameter.pageName else {
				return
			}
			pixelParameter.pageName = newValue
		}
	}

	internal mutating func prepareForTracking() {
		guard !pageName.isEmpty else {
			fatalError("pageName must be set")
		}
		parameters.removeAll()
		let timeStamp = Int(NSDate().timeIntervalSince1970 * 1000)
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		pixelParameter.timestamp = timeStamp
		pixelParameter.pageName = pageName
		parameters.append(pixelParameter)
		parameters.append(DefaultGeneralParameter(everId: everId,timestamp: timeStamp, timezoneOffset: timeZoneOffset, userAgent: buildUserAgent))
		if let customer = customer {
			parameters.append(CustomerParameter(customer: customer))
		}
//		if let product = product {
//			parameters.append(ProductParameter(product: product))
//		}
	}
}