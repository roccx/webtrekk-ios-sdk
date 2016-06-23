import Foundation

internal final class UrlCreator {

	internal static func createUrlFromEvent(event: TrackingEvent, serverUrl: String, trackingId: String) -> NSURLComponents? {
		return nil
		/*
		guard let baseUrl = NSURLComponents(string: "\(serverUrl)/\(trackingId)/wt") else {
			return nil
		}

		var items = [NSURLQueryItem]()

		let properties = event.properties

		items.append(NSURLQueryItem(name: "eid", value: properties.everId))
		items.append(NSURLQueryItem(name: "ps", value: "\(properties.samplingRate)"))
		items.append(NSURLQueryItem(name: "mts", value: "\(Int64(properties.timestamp.timeIntervalSince1970 * 1000))"))
		items.append(NSURLQueryItem(name: "tz", value: "\(properties.timeZone.daylightSavingTimeOffset / 60 / 60)"))
		items.append(NSURLQueryItem(name: "X-WT-UA", value: properties.userAgent))

		if let firstStart = properties.isFirstAppStart where firstStart {
			items.append(NSURLQueryItem(name: "one", value: "1"))
		}

		if let ipAddress = properties.ipAddress {
			items.append(NSURLQueryItem(name: "X-WT-IP", value: ipAddress))
		}

		if let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String {
			items.append(NSURLQueryItem(name: "la", value: language))
		}

		var pageName: String = ""
		switch event.kind {
		case .action(let actionEvent):
			let actionProperties = actionEvent.actionProperties
			items += actionProperties.category.map({NSURLQueryItem(name: "ck\($0.index)", value: $0.name)})
			items.append(NSURLQueryItem(name: "ct", value: actionProperties.name))
			items += actionProperties.session.map({NSURLQueryItem(name: "cs\($0.index)", value: $0.name)}) // FIXME: duplicated with page params?
			if let ecommerceProperties = actionEvent.ecommerceProperties {
				items += ecommerceProperties.asQueryItems()
			}
			if let pageProperties = actionEvent.pageProperties {  // FIXME: NEEDS TO BE Available for PageName
				items += pageProperties.asQueryItems()
				pageName = pageProperties.name
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
			}

			if let ecommerceProperties = mediaEvent.ecommerceProperties {
				items += ecommerceProperties.asQueryItems()
			}

			if let pageProperties = mediaEvent.pageProperties { // FIXME: NEEDS TO BE Available for PageName
				items += pageProperties.asQueryItems()
				pageName = pageProperties.name
			}

		case .page(let pageEvent):
			items += pageEvent.pageProperties.asQueryItems()
			pageName = pageEvent.pageProperties.name


			if let advertisementProperties = pageEvent.advertisementProperties {
				items.append(NSURLQueryItem(name: "mc", value: advertisementProperties.advertisement))
				items += advertisementProperties.campaign.map({NSURLQueryItem(name: "cc\($0.index)", value: $0.name)})
			}

			if let ecommerceProperties = pageEvent.ecommerceProperties {
				items += ecommerceProperties.asQueryItems()
			}

			if let userProperties = pageEvent.userProperties {
				items += userProperties.asQueryItems()
			}
		}
		let screenDimension = Webtrekk.screenDimensions()
		let p = "\(Webtrekk.pixelVersion),\(pageName),0,\(screenDimension.width)x\(screenDimension.height),32,0,\(Int64(properties.timestamp.timeIntervalSince1970 * 1000)),0,0,0"
		items = [NSURLQueryItem(name: "p", value: p)] + items

		items += [NSURLQueryItem(name: "eor", value: nil)]
		baseUrl.queryItems = items
		return baseUrl
	}

}


private extension EcommerceProperties {

	private func asQueryItems() ->  [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		items += categories.map({NSURLQueryItem(name: "cb\($0.index)", value: $0.name)})
		if let currency = currency {
			items.append(NSURLQueryItem(name: "cr", value: currency))
		}
		if let orderNumber = orderNumber {
			items.append(NSURLQueryItem(name: "oi", value: orderNumber))
		}
		items.append(NSURLQueryItem(name: "st", value: status.rawValue))
		items.append(NSURLQueryItem(name: "ov", value: "\(totalValue)"))
		if let voucherValue = voucherValue {
			items.append(NSURLQueryItem(name: "cb563", value: "\(voucherValue)"))
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
		if !categories.isEmpty {
			items += categories.map({NSURLQueryItem(name: "mg\($0.index)", value: $0.name)})
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
		items += categories.map({NSURLQueryItem(name: "cg\($0.index)", value: $0.name)})
		items += page.map({NSURLQueryItem(name: "cp\($0.index)", value: $0.name)})
		items += session.map({NSURLQueryItem(name: "cs\($0.index)", value: $0.name)})
		return items
	}
}


private extension UserProperties {

	private func asQueryItems() -> [NSURLQueryItem] {
		var items = [NSURLQueryItem]()
		items += categories.map({NSURLQueryItem(name: "uc\($0.index)", value: $0.name)})
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
		if let eMail = eMail {
			items = items.filter({$0.name != "uc700"})
			items.append(NSURLQueryItem(name: "uc700", value: eMail))
		}
		if let eMailReceiverId = eMailReceiverId {
			items = items.filter({$0.name != "uc701"})
			items.append(NSURLQueryItem(name: "uc701", value: eMailReceiverId))
		}
		if let firstName = firstName {
			items = items.filter({$0.name != "uc703"})
			items.append(NSURLQueryItem(name: "uc703", value: firstName))
		}
		if let gender = gender {
			items = items.filter({$0.name != "uc706"})
			items.append(NSURLQueryItem(name: "uc706", value: gender == UserProperties.Gender.male ? "1" :  "2"))
		}
		if let lastName = lastName {
			items = items.filter({$0.name != "uc704"})
			items.append(NSURLQueryItem(name: "uc704", value: lastName))
		}
		if let newsletter = newsletter {
			items = items.filter({$0.name != "uc702"})
			items.append(NSURLQueryItem(name: "uc702", value: newsletter ? "1" : "2"))
		}
		if let number = number {
			items.append(NSURLQueryItem(name: "cd", value: number))
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
		if let zip = zip {
			items = items.filter({$0.name != "uc710"})
			items.append(NSURLQueryItem(name: "uc710", value: zip))
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


//private extension Event {
//	private func dictionaryAsQueryItem(dictionary: [String: String]) -> [NSURLQueryItem] {
//		guard !dictionary.isEmpty else {
//			return [NSURLQueryItem]()
//		}
//		var queryItems = [NSURLQueryItem]()
//		for (key, value) in dictionary {
//			queryItems.append(NSURLQueryItem(name: key, value: value))
//		}
//		return queryItems
//	}
//
//
//	private func urlProductParameters() -> [NSURLQueryItem] {
//		guard !products.isEmpty else {
//			return [NSURLQueryItem]()
//		}
//		var queryItems = [NSURLQueryItem]()
//		var currency = ""
//		var name = ""
//		var price = ""
//		var quantity = ""
//		var categorieKeys = Set<Int>()
//
//		for productParameter in products {
//			let appendix = productParameter == products.last! ? "" : ";"
//			name += "\(productParameter.name)\(appendix)"
//			currency = productParameter.currency.isEmpty ? currency : productParameter.currency
//			price += "\(productParameter.price)\(appendix)"
//			quantity += "\(productParameter.quantity)\(appendix)"
//
//			for key in productParameter.categories.keys {
//				categorieKeys.insert(key)
//			}
//
//		}
//		var categories = [Int: String] ()
//		for productParameter in products {
//			let appendix = productParameter == products.last! ? "" : ";"
//
//			for key in categorieKeys {
//				var category: String
//
//				if let cat = productParameter.categories[key] {
//					category = cat
//				} else {
//					category = ""
//				}
//
//				if let cat = categories[key] {
//					categories[key] = "\(cat)\(category)\(appendix)"
//				} else {
//					categories[key] = "\(category)\(appendix)"
//				}
//
//			}
//		}
//		queryItems.append(NSURLQueryItem(name: .ProductName, value:  name))
//		if let ecommerce = ecommerce where !ecommerce.currency.isEmpty { // when ecommerce already has a currency then don't add here
//			currency = ""
//		}
//		if !currency.isEmpty {
//			queryItems.append(NSURLQueryItem(name: .EcomCurrency, value:  currency))
//		}
//		if !price.isEmpty {
//			queryItems.append(NSURLQueryItem(name: .ProductPrice, value:  price))
//		}
//		if !quantity.isEmpty {
//			queryItems.append(NSURLQueryItem(name: .ProductQuantity, value:  quantity))
//		}
//
//		for (index, value) in categories {
//			queryItems.append(NSURLQueryItem(name: .ProductCategory, withIndex: index, value:  value))
//		}
//		return queryItems
//	}
//}



//extension ActionParameter: Parameter {
//	private var urlParameter: [NSURLQueryItem] {
//		get {
//			var queryItems = [NSURLQueryItem]()
//			queryItems.append(NSURLQueryItem(name: .ActionName, value: name))
//
//			if !categories.isEmpty {
//				for (index, value) in categories {
//					queryItems.append(NSURLQueryItem(name: .ActionCategory, withIndex: index, value: value))
//				}
//			}
//
//			if !session.isEmpty {
//				for (index, value) in session {
//					queryItems.append(NSURLQueryItem(name: .Session, withIndex: index, value: value))
//				}
//			}
//			return queryItems
//		}
//	}
//}
//
//
//extension CustomerParameter: Parameter {
//	private var birthdayFormatter: NSDateFormatter {
//		get {
//			let formatter = NSDateFormatter()
//			formatter.dateFormat = "yyyyMMdd"
//			return formatter
//		}
//	}
//
//	private var urlParameter: [NSURLQueryItem] {
//		get {
//			var queryItems = [NSURLQueryItem]()
//			var categories = self.categories
//
//			if let value = eMail.isEmpty ? categories.keys.contains(700) ? categories[700] : nil : eMail where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerEmail, value: value))
//			}
//			categories.removeValueForKey(700)
//
//			if let value = eMailReceiverId.isEmpty ? categories.keys.contains(701) ? categories[701] : nil : eMailReceiverId  where !value.isEmpty{
//				queryItems.append(NSURLQueryItem(name: .CustomerEmailReceiver, value: value))
//			}
//			categories.removeValueForKey(701)
//
//			if let value = newsletter {
//				queryItems.append(NSURLQueryItem(name: .CustomerNewsletter, value: value ? "1" : "2"))
//			} else if let value = categories[702] where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerNewsletter, value: value))
//			}
//			categories.removeValueForKey(702)
//
//			if let value = firstName.isEmpty ? categories.keys.contains(703) ? categories[703] : nil : firstName where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerFirstName, value: value))
//			}
//			categories.removeValueForKey(703)
//
//			if let value = lastName.isEmpty ? categories.keys.contains(704) ? categories[704] : nil : lastName where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerLastName, value: value))
//			}
//			categories.removeValueForKey(704)
//
//			if let value = phoneNumber.isEmpty ? categories.keys.contains(705) ? categories[705] : nil : phoneNumber where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerPhoneNumber, value: value))
//			}
//			categories.removeValueForKey(705)
//
//			if let value = gender {
//				queryItems.append(NSURLQueryItem(name: .CustomerGender, value: value.toValue()))
//			} else if let value = categories[706] where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerGender, value: value))
//			}
//			categories.removeValueForKey(706)
//
//			if let value = birthday {
//				queryItems.append(NSURLQueryItem(name: .CustomerBirthday, value: birthdayFormatter.stringFromDate(value)))
//			} else if let value = categories[707] where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerBirthday, value: value))
//			}
//			categories.removeValueForKey(707)
//
//			if let value = city.isEmpty ? categories.keys.contains(708) ? categories[708] : nil : city where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerCity, value: value))
//			}
//			categories.removeValueForKey(708)
//
//			if let value = country.isEmpty ? categories.keys.contains(709) ? categories[709] : nil : country where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerCountry, value: value))
//			}
//			categories.removeValueForKey(709)
//
//			if let value = zip.isEmpty ? categories.keys.contains(710) ? categories[710] : nil : zip where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerZip, value: value))
//			}
//			categories.removeValueForKey(710)
//
//			if let value = street.isEmpty ? categories.keys.contains(711) ? categories[711] : nil : street where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerStreet, value: value))
//			}
//			categories.removeValueForKey(711)
//
//			if let value = streetNumber.isEmpty ? categories.keys.contains(712) ? categories[712] : nil : streetNumber where !value.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerStreetNumber, value: value))
//			}
//			categories.removeValueForKey(712)
//
//			if !number.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .CustomerNumber, value: number))
//			}
//
//			if !categories.isEmpty {
//				for (index, value) in categories {
//					queryItems.append(NSURLQueryItem(name: .CustomerCategory, withIndex: index, value: value))
//				}
//			}
//			return queryItems
//		}
//	}
//}
//
//internal extension CustomerGender {
//	internal func toValue() -> String {
//		switch self {
//		case .Male:
//			return "1"
//		case .Female:
//			return "2"
//		}
//	}
//
//
//	internal static func from(value: String) -> CustomerGender? {
//		switch value {
//		case "1":
//			return .Male
//		case "2":
//			return .Female
//		default:
//			return nil
//		}
//	}
//}
//
//
//extension EcommerceParameter: Parameter {
//	private var urlParameter: [NSURLQueryItem] {
//		get {
//			var queryItems = [NSURLQueryItem]()
//			if !currency.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .EcomCurrency, value: currency))
//			}
//
//			if !categories.isEmpty {
//				for (index, value) in categories {
//					queryItems.append(NSURLQueryItem(name: .EcomCategory, withIndex: index, value: value))
//				}
//			}
//
//			if !orderNumber.isEmpty {
//				queryItems.append(NSURLQueryItem(name: .EcomOrderNumber, value: orderNumber))
//			}
//
//			queryItems.append(NSURLQueryItem(name: .EcomStatus, value: status.rawValue))
//
//			queryItems.append(NSURLQueryItem(name: .EcomTotalValue, value: "\(totalValue)"))
//
//			if let voucherValue = voucherValue {
//				queryItems.append(NSURLQueryItem(name: .EcomVoucherValue, value: "\(voucherValue)"))
//			}
//
//			return queryItems
//		}
//	}
//}


extension GeneralParameter: Parameter {
	private var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()
			queryItems.append(NSURLQueryItem(name: .EverId, value: everId))
			if firstStart {
				queryItems.append(NSURLQueryItem(name: .FirstStart, value: "1"))
			}
			if !ip.isEmpty {
				queryItems.append(NSURLQueryItem(name: .IpAddress, value: ip))
			}
			if !nationalCode.isEmpty {
				queryItems.append(NSURLQueryItem(name: .NationalCode, value: nationalCode))
			}
			queryItems.append(NSURLQueryItem(name: .SamplingRate, value: "\(samplingRate)"))
			queryItems.append(NSURLQueryItem(name: .TimeStamp, value: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))
			queryItems.append(NSURLQueryItem(name: .TimeZoneOffset, value: "\(timeZoneOffset)"))
			queryItems.append(NSURLQueryItem(name: .UserAgent, value: userAgent))

			return queryItems
		}
	}
}


//extension MediaParameter: Parameter {
//	private var urlParameter: [NSURLQueryItem] {
//		get {
//			var queryItems = [NSURLQueryItem]()
//			queryItems.append(NSURLQueryItem(name: .MediaName, value: name))
//
//			queryItems.append(NSURLQueryItem(name: .MediaAction, value: action.rawValue))
//			queryItems.append(NSURLQueryItem(name: .MediaPosition, value: "\(position)"))
//			queryItems.append(NSURLQueryItem(name: .MediaDuration, value: "\(duration)"))
//			queryItems.append(NSURLQueryItem(name: .MediaTimeStamp, value: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))
//
//			if let bandwidth = bandwidth {
//				queryItems.append(NSURLQueryItem(name: .MediaBandwidth, value: "\(bandwidth)"))
//			}
//
//			if let mute = mute {
//				queryItems.append(NSURLQueryItem(name: .MediaMute, value: mute ? "1" : "0"))
//			}
//
//			if let volume = volume {
//				queryItems.append(NSURLQueryItem(name: .MediaVolume, value: "\(volume)"))
//			}
//
//			if !categories.isEmpty {
//				for (index, value) in categories {
//					queryItems.append(NSURLQueryItem(name: .MediaCategories, withIndex: index, value: value))
//				}
//			}
//
//			return queryItems
//		}
//	}
//}


//extension PageParameter: Parameter {
//	private var urlParameter: [NSURLQueryItem] {
//		get {
//			var queryItems = [NSURLQueryItem]()
//
//			if !page.isEmpty {
//				for (index, value) in page {
//					queryItems.append(NSURLQueryItem(name: .Page, withIndex: index, value: value))
//				}
//			}
//
//			if !categories.isEmpty {
//				for (index, value) in categories {
//					queryItems.append(NSURLQueryItem(name: .PageCategory, withIndex: index, value: value))
//				}
//			}
//
//			if !session.isEmpty {
//				for (index, value) in session {
//					queryItems.append(NSURLQueryItem(name: .Session, withIndex: index, value: value))
//				}
//			}
//
//			return queryItems
//		}
//	}
//}


extension PixelParameter: Parameter {
	private var urlParameter: [NSURLQueryItem] {
		get {
			return [NSURLQueryItem(name: .Pixel, value: "\(version),\(pageName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(Int64(timeStamp.timeIntervalSince1970 * 1000)),0,0,0")]
		}
	}
}

private protocol Parameter{
	var urlParameter: [NSURLQueryItem] { get }
}

internal extension CrossDeviceBridgeParameter {
	internal func toParameter() -> [String: String] {
		var result = [String: String]()
		for item in [email, phone, address, facebook, twitter, googlePlus, linkedIn] {
			guard let item = item else {
				continue
			}
			result.updateValues(item.toParameter())
		}
		return result
	}
}


internal extension CrossDeviceBridgeAttributes {
	internal func toParameter() -> [String: String] {
		switch self {
		case .Email(let plain, let md5, let sha256):
			return encodeToParameter(plain: plain, md5: md5, md5Key: .CdbEmailMd5, sha256: sha256, sha256Key: .CdbEmailSha256) { text in
				return text.lowercaseString

			}
		case .Phone(let plain, let md5, let sha256):
			return encodeToParameter(plain: plain, md5: md5, md5Key: .CdbPhoneMd5, sha256: sha256, sha256Key: .CdbPhoneSha256) { text in
				return text.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "0123456789").invertedSet).joinWithSeparator("")
			}
		case .Address(let addressContainer, let md5, let sha256):
			return encodeToParameter(plain: addressContainer != nil ? addressContainer?.toLine() : nil, md5: md5, md5Key: .CdbAddressMd5, sha256: sha256, sha256Key: .CdbAddressSha256) { text in
				let result = text.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("ä", withString: "ae").stringByReplacingOccurrencesOfString("ö", withString: "oe").stringByReplacingOccurrencesOfString("ü", withString: "ue").stringByReplacingOccurrencesOfString("ß", withString: "ss").stringByReplacingOccurrencesOfString("_", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
				if let regex = try? NSRegularExpression(pattern: "str(\\.)?(|){1,}", options: NSRegularExpressionOptions.CaseInsensitive) {
					return regex.stringByReplacingMatchesInString(result, options: .WithTransparentBounds, range: NSMakeRange(0, result.characters.count), withTemplate: "strasse")
				}
				return result
			}
		case .Facebook(let id):
			return [ParameterName.CdbFacebook.rawValue: id]
		case .Twitter(let id):
			return [ParameterName.CdbTwitter.rawValue: id]
		case .GooglePlus(let id):
			return [ParameterName.CdbGooglePlus.rawValue: id]
		case .LinkedIn(let id):
			return [ParameterName.CdbLinkedIn.rawValue: id]
		}
	}


	private func encodeToParameter(plain plain: String?, md5: String?, md5Key: ParameterName, sha256: String?, sha256Key: ParameterName, normalizer: (String) -> String) -> [String: String] {
		var result = [String: String]()
		if let plain = plain {
			// computate md5 and sha256
			let text = normalizer(plain)
			result[md5Key.rawValue] = self.md5(text)
			result[sha256Key.rawValue] = self.sha256(text)
		}
		else {
			// add if not nil
			if let md5 = md5 {
				result[md5Key.rawValue] = md5
			}
			if let sha256 = sha256 {
				result[sha256Key.rawValue] = sha256
			}
		}
		return result
	}


	private func md5(string: String) -> String{
		return string.md5()
	}


	private func sha256(string: String) -> String{
		return string.sha256()*/
	}
}
