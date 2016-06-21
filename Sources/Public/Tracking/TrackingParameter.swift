import UIKit
import ReachabilitySwift


public protocol TrackingParameter {
	var generalParameter:   GeneralParameter    { get set }
	var pixelParameter:     PixelParameter      { get set }

	var customParameters:   [String: String]    { get set }
	var productParameters:  [ProductParameter]  { get set }

//	var pageParameter:      PageParameter?      { get set }
//	var mediaParameter:     MediaParameter?     { get set }
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
//		if let ecommerce = ecommerceParameter where !ecommerce.currency.isEmpty { // when ecommerce already has a currency then don't add here
//			currency = ""
//		}
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