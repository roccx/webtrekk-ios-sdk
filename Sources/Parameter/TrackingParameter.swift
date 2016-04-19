import UIKit


public protocol TrackingParameter {
	var generalParameter:   GeneralParameter    { get }
	var pixelParameter:     PixelParameter      { get }

	var customParameters:   [String: String]    { get set }
	var customerParameter:  CustomerParameter?  { get set }
	var ecommerceParameter: EcommerceParameter? { get set }
	var productParameters:  [ProductParameter]  { get set }

	var actionParameter:    ActionParameter?    { get set }
	var pageParameter:      PageParameter?      { get set }
	var mediaParameter:     MediaParameter?     { get set }

	func urlWithAllParameter(config: TrackerConfiguration) -> String
}

public extension TrackingParameter {
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
}

internal extension TrackingParameter {
	internal func urlProductParameters() -> String {
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
		urlParameter += "&\(ParameterName.urlParameter(fromName: .ProductName, andValue: name))"
		if !currency.isEmpty {
			urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomCurrency, andValue: currency))"
		}
		if !price.isEmpty {
			urlParameter += "&\(ParameterName.urlParameter(fromName: .ProductPrice, andValue: price))"
		}
		if !quantity.isEmpty {
			urlParameter += "&\(ParameterName.urlParameter(fromName: .ProductQuantity, andValue: quantity))"
		}

		for (index, value) in categories {
			urlParameter += "&\(ParameterName.urlParameter(fromName: .ProductCategory, withIndex: index, andValue: value))"
		}
		return urlParameter
	}
}