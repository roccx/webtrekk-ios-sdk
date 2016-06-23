import Foundation


internal final class UrlCreator {

	internal static func createUrlFromEvent(request: TrackerRequest, serverUrl: NSURL, webtrekkId: String) -> NSURL? {
		guard let baseUrl = NSURLComponents(URL: serverUrl.URLByAppendingPathComponent("\(webtrekkId)").URLByAppendingPathComponent("wt"), resolvingAgainstBaseURL: false) else {
			logError("Url could not be created from ServerUrl '\(serverUrl)' and WebtrekkId '\(webtrekkId)'.")
			return nil
		}

		var items = [NSURLQueryItem]()

		let properties = request.properties

		items.append(NSURLQueryItem(name: "eid", value: properties.everId))
		items.append(NSURLQueryItem(name: "ps", value: "\(properties.samplingRate)"))
		items.append(NSURLQueryItem(name: "mts", value: "\(Int64(properties.timestamp.timeIntervalSince1970 * 1000))"))
		items.append(NSURLQueryItem(name: "tz", value: "\(properties.timeZone.daylightSavingTimeOffset / 60 / 60)"))
		items.append(NSURLQueryItem(name: "X-WT-UA", value: properties.userAgent))

		if properties.isFirstEventOfApp {
			items.append(NSURLQueryItem(name: "one", value: "1"))
		}

		if properties.isFirstEventOfSession {
			items.append(NSURLQueryItem(name: "fns", value: "1"))
		}

		if let ipAddress = properties.ipAddress {
			items.append(NSURLQueryItem(name: "X-WT-IP", value: ipAddress))
		}

		if let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String {
			items.append(NSURLQueryItem(name: "la", value: language))
		}

		items += request.userProperties.asQueryItems()

		if let interfaceOrientation = properties.interfaceOrientation {
			switch interfaceOrientation {
			case .LandscapeLeft, .LandscapeRight: items.append(NSURLQueryItem(name: "cp783", value: "landscape"))
			case .Portrait, .PortraitUpsideDown: items.append(NSURLQueryItem(name: "cp783", value: "portrait"))
			default: items.append(NSURLQueryItem(name: "cp783", value: "undefined"))
			}

		}
		if let connectionType = properties.connectionType {
			switch connectionType {
			case .cellular_2G: items.append(NSURLQueryItem(name: "cs807", value: "2G"))
			case .cellular_3G: items.append(NSURLQueryItem(name: "cs807", value: "3G"))
			case .cellular_4G: items.append(NSURLQueryItem(name: "cs807", value: "LTE"))
			case .offline:     items.append(NSURLQueryItem(name: "cs807", value: "offline"))
			case .other:       items.append(NSURLQueryItem(name: "cs807", value: "unknown"))
			case .wifi:        items.append(NSURLQueryItem(name: "cs807", value: "WIFI"))
			}
		}
		// FIXME: NEEED SESSION DETAILS
//		if let session = event.session { 
//			items += userProperties.asQueryItems()
//		}
		var pageName: String = ""
		switch request.event {
		case .action(let actionEvent):
			let actionProperties = actionEvent.actionProperties
			if let details = actionProperties.details {
				items += details.map({NSURLQueryItem(name: "ck\($0.index)", value: $0.value)})
			}
			items.append(NSURLQueryItem(name: "ct", value: actionProperties.name))

			items += actionEvent.ecommerceProperties.asQueryItems()
			items += actionEvent.pageProperties.asQueryItems()
			if let name = actionEvent.pageProperties.name {
				pageName = name
			}

		case .media(let mediaEvent):
			items += mediaEvent.mediaProperties.asQueryItems(properties.timestamp)

			switch mediaEvent.kind {
			case .finish: items.append(NSURLQueryItem(name: "mk", value: "eof"))
			case .pause: items.append(NSURLQueryItem(name: "mk", value: "pause"))
			case .play: items.append(NSURLQueryItem(name: "mk", value: "play"))
			case .position: items.append(NSURLQueryItem(name: "mk", value: "pos"))
			case .seek: items.append(NSURLQueryItem(name: "mk", value: "seek"))
			case .stop: items.append(NSURLQueryItem(name: "mk", value: "stop"))
			case .custom(name: let name): items.append(NSURLQueryItem(name: "mk", value: name))
			}


			items += mediaEvent.ecommerceProperties.asQueryItems()

			items += mediaEvent.pageProperties.asQueryItems()
			if let name = mediaEvent.pageProperties.name {
				pageName = name
			}

		case .pageView(let pageViewEvent):
			items += pageViewEvent.pageProperties.asQueryItems()
			if let name = pageViewEvent.pageProperties.name {
				pageName = name
			}


			if let id = pageViewEvent.advertisementProperties.id {
				items.append(NSURLQueryItem(name: "mc", value: id))
			}
			if let details = pageViewEvent.advertisementProperties.details {
				items += details.map({NSURLQueryItem(name: "cc\($0.index)", value: $0.value)})
			}

			items += pageViewEvent.ecommerceProperties.asQueryItems()

		}
		guard !pageName.isEmpty else {
			logError("Url creation could not finish because page name was not set in event '\(request)'.")
			return nil
		}

		let p = "400,\(pageName),0,\(request.properties.screenSize?.width ?? 0)x\(request.properties.screenSize?.height ?? 0),32,0,\(Int64(properties.timestamp.timeIntervalSince1970 * 1000)),0,0,0"
		items = [NSURLQueryItem(name: "p", value: p)] + items

		items += [NSURLQueryItem(name: "eor", value: nil)]
		baseUrl.queryItems = items
		return baseUrl.URL
	}

}


private extension EcommerceProperties {

	private func asQueryItems() ->  [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let currencyCode = currencyCode {
			items.append(NSURLQueryItem(name: "cr", value: currencyCode))
		}
		if let details = details {
			items += details.map({NSURLQueryItem(name: "cb\($0.index)", value: $0.value)})
		}
		if let orderNumber = orderNumber {
			items.append(NSURLQueryItem(name: "oi", value: orderNumber))
		}
		if let status = status {
			switch status {
			case .addedToBasket:
				items.append(NSURLQueryItem(name: "st", value: "add"))
			case .purchased:
				items.append(NSURLQueryItem(name: "st", value: "conf"))
			case .viewed:
				items.append(NSURLQueryItem(name: "st", value: "view"))
			}
		}
		if let totalValue = totalValue {
			items.append(NSURLQueryItem(name: "ov", value: "\(totalValue)"))
		}
		if let voucherValue = voucherValue {
			items.append(NSURLQueryItem(name: "cb563", value: "\(voucherValue)"))
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
			quantities.append("\(product.quantity != nil ? "\(product.quantity)" : "" )")
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

		items.append(NSURLQueryItem(name: "ba", value: names.joinWithSeparator(";")))
		items.append(NSURLQueryItem(name: "co", value: prices.joinWithSeparator(";")))
		items.append(NSURLQueryItem(name: "qn", value: quantities.joinWithSeparator(";")))
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
		items.append(NSURLQueryItem(name: "ba", value: name))
		if let price = price {
			items.append(NSURLQueryItem(name: "co", value: "\(price)"))
		}
		if let quantity = quantity {
			items.append(NSURLQueryItem(name: "qn", value: "\(quantity)"))
		}
		return items
	}
}


private extension MediaProperties {

	private func asQueryItems(timestamp: NSDate) -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		if let bandwidth = bandwidth {
			items.append(NSURLQueryItem(name: "bw", value: "\(Int64(bandwidth))"))
		}
		if let groups = groups {
			items += groups.map({NSURLQueryItem(name: "mg\($0.index)", value: $0.value)})
		}
		if let duration = duration {
			items.append(NSURLQueryItem(name: "mt2", value: "\(Int64(duration))"))
		}
		else {
			items.append(NSURLQueryItem(name: "mt2", value: "\(0)"))
		}
		items.append(NSURLQueryItem(name: "mi", value: name))

		if let position = position {
			items.append(NSURLQueryItem(name: "mt1", value: "\(Int64(position))"))
		}
		else {
			items.append(NSURLQueryItem(name: "mt1", value: "\(0)"))
		}
		if let soundIsMuted = soundIsMuted {
			items.append(NSURLQueryItem(name: "mut", value: soundIsMuted ? "1" : "0"))
		}
		if let soundVolume = soundVolume {
			items.append(NSURLQueryItem(name: "mut", value: "\(Int64(soundVolume * 100))"))
		}
		items.append(NSURLQueryItem(name: "x", value: "\(Int64(timestamp.timeIntervalSince1970 * 1000))"))
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
			items.append(NSURLQueryItem(name: "uc707", value: birthdayFormatter.stringFromDate(birthday)))
		}
		if let city = city {
			items = items.filter({$0.name != "uc708"})
			items.append(NSURLQueryItem(name: "uc708", value: city))
		}
		if let country = country {
			items = items.filter({$0.name != "uc709"})
			items.append(NSURLQueryItem(name: "uc709", value: country))
		}
		if let emailAddress = emailAddress {
			items = items.filter({$0.name != "uc700"})
			items.append(NSURLQueryItem(name: "uc700", value: emailAddress))
		}
		if let emailReceiverId = emailReceiverId {
			items = items.filter({$0.name != "uc701"})
			items.append(NSURLQueryItem(name: "uc701", value: emailReceiverId))
		}
		if let firstName = firstName {
			items = items.filter({$0.name != "uc703"})
			items.append(NSURLQueryItem(name: "uc703", value: firstName))
		}
		if let gender = gender {
			items = items.filter({$0.name != "uc706"})
			items.append(NSURLQueryItem(name: "uc706", value: gender == UserProperties.Gender.male ? "1" :  "2"))
		}
		if let id = id {
			items.append(NSURLQueryItem(name: "cd", value: id))
		}
		if let lastName = lastName {
			items = items.filter({$0.name != "uc704"})
			items.append(NSURLQueryItem(name: "uc704", value: lastName))
		}
		if let newsletterSubscribed = newsletterSubscribed {
			items = items.filter({$0.name != "uc702"})
			items.append(NSURLQueryItem(name: "uc702", value: newsletterSubscribed ? "1" : "2"))
		}
		if let phoneNumber = phoneNumber {
			items = items.filter({$0.name != "uc705"})
			items.append(NSURLQueryItem(name: "uc705", value: phoneNumber))
		}
		if let street = street {
			items = items.filter({$0.name != "uc711"})
			items.append(NSURLQueryItem(name: "uc711", value: street))
		}
		if let streetNumber = streetNumber {
			items = items.filter({$0.name != "uc712"})
			items.append(NSURLQueryItem(name: "uc712", value: streetNumber))
		}
		if let zipCode = zipCode {
			items = items.filter({$0.name != "uc710"})
			items.append(NSURLQueryItem(name: "uc710", value: zipCode))
		}

		return items
	}


	private var birthdayFormatter: NSDateFormatter {
		get {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyyMMdd"
			return formatter
		}
	}
}