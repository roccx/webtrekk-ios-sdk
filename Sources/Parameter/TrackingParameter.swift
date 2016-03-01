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
			if let eid = userDefaults.stringForKey(UserStoreKey.Eid) {
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

	func urlProductParameters() -> String {
		guard !productParameters.isEmpty else {
			return ""
		}
		var urlParameter = ""
		var currency = ""
		var name = ""
		var price = ""
		var quantity = ""
		var categorieKeys = Set<Int>()

		for productParameter in productParameters {
			let appendix = productParameter == productParameters.last! ? "" : ";"
			name += "\(productParameter.name)\(appendix)"
			currency = productParameter.currency.isEmpty ? currency : productParameter.currency
			price += "\(productParameter.price)\(appendix)"
			quantity += "\(productParameter.quantity)\(appendix)"

			for key in productParameter.categories.keys {
				categorieKeys.insert(key)
			}

		}
		var categories = [Int: String] ()
		for productParameter in productParameters {
			let appendix = productParameter == productParameters.last! ? "" : ";"

			for key in categorieKeys {
				var category: String

				if let cat = productParameter.categories[key] {
					category = cat
				} else {
					category = ""
				}

				if let cat = categories[key] {
					categories[key] = "\(cat)\(category)\(appendix)"
				} else {
					categories[key] = "\(category)\(appendix)"
				}

			}
		}
		urlParameter += "\(ParameterName.ProductName.rawValue)=\(name.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
		urlParameter += "&\(ParameterName.EcomCurrency.rawValue)=\(currency)"
		urlParameter += "&\(ParameterName.ProductPrice.rawValue)=\(price)"
		urlParameter += "&\(ParameterName.ProductQuantity.rawValue)=\(quantity)"
		for (key, value) in categories {
			urlParameter += "&\(ParameterName.ProductCategory.rawValue)\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
		}
		return urlParameter
	}
}

extension ActionTrackingParameter {
	func urlWithAllParameter(config: TrackerConfiguration) -> String {
		var url = config.baseUrl.absoluteString
		url += "?\(pixelParameter.urlParameter)"
		url += "&\(generalParameter.urlParameter)"
		url += "&\(actionParameter.urlParameter)"
		if !productParameters.isEmpty {
			url += "&\(urlProductParameters())"
		}
		return url
	}
}


public struct ActionTrackingParameter: TrackingParameter {
	public var actionParameter:    ActionParameter
	public var ecommerceParameter: EcommerceParameter?
	public var generalParameter:   GeneralParameter
	public var pixelParameter:     PixelParameter
	public var productParameters:  [ProductParameter]


	public init(actionParameter: ActionParameter, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = [ProductParameter]()) {

		let timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.actionParameter = actionParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}

}

public struct PageTrackingParameter: TrackingParameter{
	public var pageParameter:      PageParameter
	public var ecommerceParameter: EcommerceParameter?
	public var generalParameter:   GeneralParameter
	public var pixelParameter:     PixelParameter
	public var productParameters:  [ProductParameter]

	public init(pageParameter: PageParameter, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = [ProductParameter]()) {

		let timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.pageParameter = pageParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}
}