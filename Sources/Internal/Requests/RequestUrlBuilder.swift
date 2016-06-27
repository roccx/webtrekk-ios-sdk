import CryptoSwift
import Foundation


internal final class RequestUrlBuilder {

	internal var baseUrl: NSURL


	internal init(serverUrl: NSURL, webtrekkId: String) {
		self.baseUrl = RequestUrlBuilder.buildBaseUrl(serverUrl: serverUrl, webtrekkId: webtrekkId)
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	private static func buildBaseUrl(serverUrl serverUrl: NSURL, webtrekkId: String) -> NSURL {
		return serverUrl.URLByAppendingPathComponent(webtrekkId).URLByAppendingPathComponent("wt")
	}


	internal var serverUrl: NSURL {
		didSet {
			guard serverUrl != oldValue else {
				return
			}

			baseUrl = RequestUrlBuilder.buildBaseUrl(serverUrl: serverUrl, webtrekkId: webtrekkId)
		}
	}


	internal func urlForRequest(request: TrackerRequest) -> NSURL? {
		let properties = request.properties

		var parameters = [NSURLQueryItem]()
		parameters.append(name: "eid", value: properties.everId)
		parameters.append(name: "ps", value: "\(properties.samplingRate)")
		parameters.append(name: "mts", value: "\(Int64(properties.timestamp.timeIntervalSince1970 * 1000))")
		parameters.append(name: "tz", value: "\(properties.timeZone.daylightSavingTimeOffset / 60 / 60)")
		parameters.append(name: "X-WT-UA", value: properties.userAgent)

		if properties.isFirstEventOfApp {
			parameters.append(name: "one", value: "1")
		}

		if properties.isFirstEventOfSession {
			parameters.append(name: "fns", value: "1")
		}

		if let ipAddress = properties.ipAddress {
			parameters.append(name: "X-WT-IP", value: ipAddress)
		}

		if let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String {
			parameters.append(name: "la", value: language)
		}

		parameters += request.userProperties.asQueryItems()

		#if !os(watchOS)
			if let interfaceOrientation = properties.interfaceOrientation {
				switch interfaceOrientation {
				case .LandscapeLeft, .LandscapeRight: parameters.append(name: "cp783", value: "landscape")
				case .Portrait, .PortraitUpsideDown: parameters.append(name: "cp783", value: "portrait")
				default: parameters.append(name: "cp783", value: "undefined")
				}
			}
		#endif

		if let connectionType = properties.connectionType {
			switch connectionType {
			case .cellular_2G: parameters.append(name: "cs807", value: "2G")
			case .cellular_3G: parameters.append(name: "cs807", value: "3G")
			case .cellular_4G: parameters.append(name: "cs807", value: "LTE")
			case .offline:     parameters.append(name: "cs807", value: "offline")
			case .other:       parameters.append(name: "cs807", value: "unknown")
			case .wifi:        parameters.append(name: "cs807", value: "WIFI")
			}
		}

		if let sessionDetails = properties.sessionDetails {
			parameters += sessionDetails.map({NSURLQueryItem(name: "cs\($0.index)", value: $0.value)})
		}

		parameters += request.crossDeviceProperties.asQueryItems()

		var pageName: String = ""
		switch request.event {
		case .action(let actionEvent):
			let actionProperties = actionEvent.actionProperties
			guard !actionProperties.name.isEmpty else {
				logError("Url creation could not finish because action name on an action event was not set '\(request)'.")
				return nil
			}
			if let details = actionProperties.details {
				parameters += details.map({NSURLQueryItem(name: "ck\($0.index)", value: $0.value)})
			}
			parameters.append(name: "ct", value: actionProperties.name)

			parameters += actionEvent.ecommerceProperties.asQueryItems()
			parameters += actionEvent.pageProperties.asQueryItems()
			if let name = actionEvent.pageProperties.name {
				pageName = name
			}
			if !actionEvent.customProperties.isEmpty {
				parameters += actionEvent.customProperties.map({NSURLQueryItem(name: $0, value: $1)})
			}

		case .media(let mediaEvent):
			guard !mediaEvent.mediaProperties.name.isEmpty else {
				logError("Url creation could not finish because media name on an media event was not set '\(request)'.")
				return nil
			}
			parameters += mediaEvent.mediaProperties.asQueryItems(properties.timestamp)

			let actionId: String
			switch mediaEvent.action {
			case .finish:           actionId = "finish"
			case .pause:            actionId = "pause"
			case .play:             actionId = "play"
			case .position:         actionId = "pos"
			case .seek:             actionId = "seek"
			case .stop:             actionId = "stop"
			case let .custom(name): actionId = name
			}
			parameters.append(name: "mk", value: actionId)

			parameters += mediaEvent.ecommerceProperties.asQueryItems()

			parameters += mediaEvent.pageProperties.asQueryItems()
			if let name = mediaEvent.pageProperties.name {
				pageName = name
			}

			if !mediaEvent.customProperties.isEmpty {
				parameters += mediaEvent.customProperties.map({NSURLQueryItem(name: $0, value: $1)})
			}

		case .pageView(let pageViewEvent):
			parameters += pageViewEvent.pageProperties.asQueryItems()
			if let name = pageViewEvent.pageProperties.name {
				pageName = name
			}


			if let id = pageViewEvent.advertisementProperties.id {
				parameters.append(name: "mc", value: id)
			}
			if let details = pageViewEvent.advertisementProperties.details {
				parameters += details.map({NSURLQueryItem(name: "cc\($0.index)", value: $0.value)})
			}

			parameters += pageViewEvent.ecommerceProperties.asQueryItems()

			if !pageViewEvent.customProperties.isEmpty {
				parameters += pageViewEvent.customProperties.map({NSURLQueryItem(name: $0, value: $1)})
			}

		}
		guard !pageName.isEmpty else {
			logError("Url creation could not finish because page name was not set in event '\(request)'.")
			return nil
		}

		let p = "400,\(pageName),0,\(request.properties.screenSize?.width ?? 0)x\(request.properties.screenSize?.height ?? 0),32,0,\(Int64(properties.timestamp.timeIntervalSince1970 * 1000)),0,0,0"
		parameters = [NSURLQueryItem(name: "p", value: p)] + parameters
		parameters += [NSURLQueryItem(name: "eor", value: nil)]

		guard let urlComponents = NSURLComponents(URL: baseUrl, resolvingAgainstBaseURL: true) else {
			logError("Url could not be created from ServerUrl '\(serverUrl)' and WebtrekkId '\(webtrekkId)'.")
			return nil
		}

		urlComponents.queryItems = parameters

		guard let url = urlComponents.URL else {
			logError("Cannot build URL from components: \(urlComponents)")
			return nil
		}

		return url
	}


	internal var webtrekkId: String {
		didSet {
			guard webtrekkId != oldValue else {
				return
			}

			baseUrl = RequestUrlBuilder.buildBaseUrl(serverUrl: serverUrl, webtrekkId: webtrekkId)
		}
	}
}


private extension CrossDeviceProperties {
	private func asQueryItems() -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let address = address {
			switch address {
			case let .plain(value):
				if value.isEmpty() {
					break
				}
				var result = ""
				if let regex = try? NSRegularExpression(pattern: "str(\\.)?(|){1,}", options: NSRegularExpressionOptions.CaseInsensitive) {
					result = regex.stringByReplacingMatchesInString(value.toLine() , options: .WithTransparentBounds, range: NSMakeRange(0, value.toLine() .characters.count), withTemplate: "strasse")
				}
				if result.isEmpty {
					break
				}
				items.append(name: "cdb5", value: result.md5())
				items.append(name: "cdb6", value: result.sha256())

			case let .hashed(md5, sha256):
				if let md5 = md5 {
					items.append(name: "cdb5", value: md5)
				}
				if let sha256 = sha256 {
					items.append(name: "cdb6", value: sha256)
				}
			}
		}

		if let email = emailAddress {
			switch email {
			case let .plain(value):
				let result = value.lowercaseString
				items.append(name: "cdb1", value: result.md5())
				items.append(name: "cdb2", value: result.sha256())

			case let .hashed(md5, sha256):
				if let md5 = md5 {
					items.append(name: "cdb1", value: md5)
				}
				if let sha256 = sha256 {
					items.append(name: "cdb2", value: sha256)
				}
			}
		}

		if let facebookId = facebookId {
			items.append(name: "cdb10", value: facebookId.lowercaseString)
		}

		if let googlePlusId = googlePlusId {
			items.append(name: "cdb12", value: googlePlusId.lowercaseString)
		}

		if let linkedInId = linkedInId {
			items.append(name: "cdb13", value: linkedInId.lowercaseString)
		}

		if let phoneNumber = phoneNumber {
			switch phoneNumber {
			case let .plain(value):
				let result = value.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "0123456789").invertedSet).joinWithSeparator("")
				items.append(name: "cdb3", value: result.md5())
				items.append(name: "cdb4", value: result.sha256())

			case let .hashed(md5, sha256):
				if let md5 = md5 {
					items.append(name: "cdb3", value: md5)
				}
				if let sha256 = sha256 {
					items.append(name: "cdb4", value: sha256)
				}
			}
		}

		if let twitterId = twitterId {
			items.append(name: "cdb11", value: twitterId.lowercaseString)
		}
		
		return items
	}
}


private extension CrossDeviceProperties.Address {
	private func isEmpty() -> Bool {
		if firstName != nil || lastName != nil || street != nil || streetNumber != nil || zipCode != nil {
			return false
		}
		return true
	}


	private func toLine() -> String {
		return [firstName, lastName, zipCode, street, streetNumber].filterNonNil().joinWithSeparator("|").lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("ä", withString: "ae").stringByReplacingOccurrencesOfString("ö", withString: "oe").stringByReplacingOccurrencesOfString("ü", withString: "ue").stringByReplacingOccurrencesOfString("ß", withString: "ss").stringByReplacingOccurrencesOfString("_", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
	}
}


private extension EcommerceProperties {

	private func asQueryItems() ->  [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let currencyCode = currencyCode {
			items.append(name: "cr", value: currencyCode)
		}
		if let details = details {
			items += details.map({NSURLQueryItem(name: "cb\($0.index)", value: $0.value)})
		}
		if let orderNumber = orderNumber {
			items.append(name: "oi", value: orderNumber)
		}
		items += mergeProductQueryItems()
		if let status = status {
			switch status {
			case .addedToBasket:
				items.append(name: "st", value: "add")
			case .purchased:
				items.append(name: "st", value: "conf")
			case .viewed:
				items.append(name: "st", value: "view")
			}
		}
		if let totalValue = totalValue {
			items.append(name: "ov", value: "\(totalValue)")
		}
		if let voucherValue = voucherValue {
			items.append(name: "cb563", value: "\(voucherValue)")
		}
		return items
	}

	private func mergeProductQueryItems() -> [NSURLQueryItem] {
		guard let products = products else {
			return []
		}

		guard products.count > 0 && products.count != 1 else {
			return products.map({$0.asQueryItems()})[0]
		}
		var items = [NSURLQueryItem] ()

		var names = [String]()
		var prices = [String]()
		var quantities =  [String]()
		var categoryKeys = Set<Int>()
		for product in products {
			names.append(product.name)
			prices.append(product.price ?? "")
			quantities.append("\(product.quantity != nil ? "\(product.quantity!)" : "" )")
			if let categories = product.categories {
				for category in categories {
					categoryKeys.insert(category.index)
				}
			}
		}

		var categories = Set<IndexedProperty>()

		for key in categoryKeys {
			var categoryValues = [String]()
			for product in products {
				var value = ""
				if let categories = product.categories {
					for category in categories where category.index == key {
						value = category.value
					}
				}
				categoryValues.append(value)
			}
			categories.insert(IndexedProperty(index: key, value: categoryValues.joinWithSeparator(";")))
		}

		items.append(name: "ba", value: names.joinWithSeparator(";"))
		items.append(name: "co", value: prices.joinWithSeparator(";"))
		items.append(name: "qn", value: quantities.joinWithSeparator(";"))
		items += categories.map({NSURLQueryItem(name: "ca\($0.index)", value: $0.value)})
		return items
	}
}


private extension EcommerceProperties.Product {
	private func asQueryItems() -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let categories = categories {
			items += categories.map({NSURLQueryItem(name: "ca\($0.index)", value: $0.value)})
		}
		items.append(name: "ba", value: name)
		if let price = price {
			items.append(name: "co", value: "\(price)")
		}
		if let quantity = quantity {
			items.append(name: "qn", value: "\(quantity)")
		}
		return items
	}
}


private extension MediaProperties {

	private func asQueryItems(timestamp: NSDate) -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let bandwidth = bandwidth {
			items.append(name: "bw", value: "\(Int64(bandwidth))")
		}
		if let groups = groups {
			items += groups.map({NSURLQueryItem(name: "mg\($0.index)", value: $0.value)})
		}
		if let duration = duration {
			items.append(name: "mt2", value: "\(Int64(duration))")
		}
		else {
			items.append(name: "mt2", value: "\(0)")
		}
		items.append(name: "mi", value: name)

		if let position = position {
			items.append(name: "mt1", value: "\(Int64(position))")
		}
		else {
			items.append(name: "mt1", value: "\(0)")
		}
		if let soundIsMuted = soundIsMuted {
			items.append(name: "mut", value: soundIsMuted ? "1" : "0")
		}
		if let soundVolume = soundVolume {
			items.append(name: "vol", value: "\(Int64(soundVolume * 100))")
		}
		items.append(name: "x", value: "\(Int64(timestamp.timeIntervalSince1970 * 1000))")
		return items
	}
}


private extension PageProperties {

	private func asQueryItems() -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let details = details {
			items += details.map({NSURLQueryItem(name: "cp\($0.index)", value: $0.value)})
		}
		if let groups = groups {
			items += groups.map({NSURLQueryItem(name: "cg\($0.index)", value: $0.value)})
		}
		return items
	}
}


private extension UserProperties {

	private func asQueryItems() -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let details = details {
			items += details.map({NSURLQueryItem(name: "uc\($0.index)", value: $0.value)})
		}
		if let birthday = birthday {
			items = items.filter({$0.name != "uc707"})
			items.append(name: "uc707", value: UserProperties.birthdayFormatter.stringFromDate(birthday))
		}
		if let city = city {
			items = items.filter({$0.name != "uc708"})
			items.append(name: "uc708", value: city)
		}
		if let country = country {
			items = items.filter({$0.name != "uc709"})
			items.append(name: "uc709", value: country)
		}
		if let emailAddress = emailAddress {
			items = items.filter({$0.name != "uc700"})
			items.append(name: "uc700", value: emailAddress)
		}
		if let emailReceiverId = emailReceiverId {
			items = items.filter({$0.name != "uc701"})
			items.append(name: "uc701", value: emailReceiverId)
		}
		if let firstName = firstName {
			items = items.filter({$0.name != "uc703"})
			items.append(name: "uc703", value: firstName)
		}
		if let gender = gender {
			items = items.filter({$0.name != "uc706"})
			items.append(name: "uc706", value: gender == UserProperties.Gender.male ? "1" :  "2")
		}
		if let id = id {
			items.append(name: "cd", value: id)
		}
		if let lastName = lastName {
			items = items.filter({$0.name != "uc704"})
			items.append(name: "uc704", value: lastName)
		}
		if let newsletterSubscribed = newsletterSubscribed {
			items = items.filter({$0.name != "uc702"})
			items.append(name: "uc702", value: newsletterSubscribed ? "1" : "2")
		}
		if let phoneNumber = phoneNumber {
			items = items.filter({$0.name != "uc705"})
			items.append(name: "uc705", value: phoneNumber)
		}
		if let street = street {
			items = items.filter({$0.name != "uc711"})
			items.append(name: "uc711", value: street)
		}
		if let streetNumber = streetNumber {
			items = items.filter({$0.name != "uc712"})
			items.append(name: "uc712", value: streetNumber)
		}
		if let zipCode = zipCode {
			items = items.filter({$0.name != "uc710"})
			items.append(name: "uc710", value: zipCode)
		}

		return items
	}


	private static let birthdayFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		return formatter
	}()
}



private extension Array where Element: NSURLQueryItem {

	private mutating func append(name name: String, value: String?) {
		append(Element.init(name: name, value: value))
	}
}
