import UIKit
import ReachabilitySwift


public protocol TrackingParameter {
	var generalParameter:   GeneralParameter    { get set }
	var pixelParameter:     PixelParameter      { get set }

	var customParameters:   [String: String]    { get set }
	var customerParameter:  CustomerParameter?  { get set }
	var ecommerceParameter: EcommerceParameter? { get set }
	var productParameters:  [ProductParameter]  { get set }

	var actionParameter:    ActionParameter?    { get set }
	var pageParameter:      PageParameter?      { get set }
	var mediaParameter:     MediaParameter?     { get set }
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


	public func firstStart() -> Bool {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		guard let _ = userDefaults.objectForKey(UserStoreKey.FirstStart) else {
			userDefaults.setBool(true, forKey: UserStoreKey.FirstStart)
			return true
		}
		return false
	}


	public var userAgent: String {
		get {
			let os = NSProcessInfo().operatingSystemVersion
			return "Tracking Library \(Double(pixelParameter.version/100))(iOS;\(os.majorVersion).\(os.minorVersion).\(os.patchVersion);\(UIDevice.currentDevice().modelIdentifier);\(NSLocale.currentLocale().localeIdentifier))"
		}
	}
}

internal extension TrackingParameter {

	internal func autoTrackUrlParameters() -> String {
		return ""
	}

	internal func urlProductParameters() -> [NSURLQueryItem] {
		guard !productParameters.isEmpty else {
			return [NSURLQueryItem]()
		}
		var queryItems = [NSURLQueryItem]()
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
		queryItems.append(NSURLQueryItem(name: .ProductName, value:  name))
		if let ecommerce = ecommerceParameter where !ecommerce.currency.isEmpty { // when ecommerce already has a currency then don't add here
			currency = ""
		}
		if !currency.isEmpty {
			queryItems.append(NSURLQueryItem(name: .EcomCurrency, value:  currency))
		}
		if !price.isEmpty {
			queryItems.append(NSURLQueryItem(name: .ProductPrice, value:  price))
		}
		if !quantity.isEmpty {
			queryItems.append(NSURLQueryItem(name: .ProductQuantity, value:  quantity))
		}

		for (index, value) in categories {
			queryItems.append(NSURLQueryItem(name: .ProductCategory, withIndex: index, value:  value))
		}
		return queryItems
	}
}