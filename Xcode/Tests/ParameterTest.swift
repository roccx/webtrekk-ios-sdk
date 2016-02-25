import XCTest


@testable import Webtrekk


class ParameterTest: XCTestCase {

	func testActionParameter() {
		let actionName = "click"
		let actionParameter = DefaultActionParameter(name:actionName)
		var actionTrackingParameter = DefaultActionTrackingParameter(actionParameter: actionParameter)
		XCTAssertEqual(actionTrackingParameter.actionParameter.name, actionName)
		XCTAssertEqual(actionTrackingParameter.generalParameter.userAgent, "Tracking Library 4.0 (iOS; 9. 3. 0; Simulator; en_US)")
		XCTAssertEqual(actionTrackingParameter.pixelParameter.timeStamp, actionTrackingParameter.generalParameter.timeStamp)
	}


	func testActionParameterWithMore() {
		let actionName = "click"
		var categories = [Int: String]()
		for i in 1...10 {
			categories[i] = "Categorie Parameter \(i)"
		}
		var session = [Int: String]()
		for i in 1...10 {
			session[i] = "Session;Parameter \(i)"
		}
		var products = [ProductParameter]()
		for i in 1...3 {
			var categories = [Int: String]()
			for j in i...7 {
				categories[j] = "Category(\(j))InProduct(\(i))"
			}

			products.append(DefaultProductParameter(categories: categories, currency: i % 2 == 0 ? "" : "EUR", name: "Prodcut\(i)", price: "\(Double(i) * 2.5)", quantity: "\(i)"))
		}
		let actionParameter = DefaultActionParameter(categories: categories, name:actionName, session: session)
		var actionTrackingParameter = DefaultActionTrackingParameter(actionParameter: actionParameter, productParameters: products)
		XCTAssertEqual(actionTrackingParameter.actionParameter.name, actionName)
		XCTAssertEqual(actionTrackingParameter.generalParameter.userAgent, "Tracking Library 4.0 (iOS; 9. 3. 0; Simulator; en_US)")
		XCTAssertEqual(actionTrackingParameter.pixelParameter.timeStamp, actionTrackingParameter.generalParameter.timeStamp)
		print(actionTrackingParameter.urlWithAllParameter(DefaultTrackerConfiguration(serverUrl: "http://webtrack.de/tracking", trackingId: "12341231234")))
	}
}

extension TrackingParameter {
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
			let appendix = productParameter.equal(productParameters.last!) ? "" : ";"
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
			let appendix = productParameter.equal(productParameters.last!) ? "" : ";"

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

extension PixelParameter {
	var urlParameter: String {
		get {
			return "\(ParameterName.Pixel.rawValue)=\(version),\(pageName),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(timeStamp),0,0,0"
		}
	}
}

extension ActionParameter {
	var urlParameter: String {
		get {
			var urlParameter = "\(ParameterName.ActionName.rawValue)=\(name)"
			if !categories.isEmpty {
				for (key, value) in categories {
					urlParameter += "&\(ParameterName.ActionCategory.rawValue)\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
				}
			}
			if !session.isEmpty {
				for (key, value) in session {
					urlParameter += "&\(ParameterName.Session.rawValue)\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
				}
			}
			return urlParameter
		}
	}
}

extension GeneralParameter {
	var urlParameter: String {
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