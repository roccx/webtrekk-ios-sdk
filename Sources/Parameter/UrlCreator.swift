import Foundation

internal final class UrlCreator {

	internal static func createUrlFromTrackingParameter(trackingParameter: TrackingParameter, andConfig config: TrackerConfiguration) -> NSURL {
		var queryItems = [NSURLQueryItem]()

		queryItems += trackingParameter.pixelParameter.urlParameter
		queryItems += trackingParameter.generalParameter.urlParameter

		if let page = trackingParameter.pageParameter {
			queryItems += page.urlParameter
		} else if let action = trackingParameter.actionParameter {
			queryItems += action.urlParameter
		} else if let media = trackingParameter.mediaParameter {
			queryItems += media.urlParameter
		}

		queryItems += trackingParameter.urlProductParameters()

		if let ecommerceParameter = trackingParameter.ecommerceParameter {
			queryItems += ecommerceParameter.urlParameter
		}

		if let customerParameter = trackingParameter.customerParameter {
			queryItems += customerParameter.urlParameter
		}

		queryItems += trackingParameter.customParametersAsQueryItem()

		guard let url = config.baseUrl.URLByAppendingQueryItems(queryItems) else {
			return config.baseUrl
		}
		
		return url
	}

}

internal extension TrackingParameter {
	internal func customParametersAsQueryItem() -> [NSURLQueryItem] {
		guard !customParameters.isEmpty else {
			return [NSURLQueryItem]()
		}
		var queryItems = [NSURLQueryItem]()
		for (key, value) in customParameters {
			queryItems.append(NSURLQueryItem(name: key, value: value))
		}
		return queryItems
	}
}

/* action
public func urlWithAllParameter(config: TrackerConfiguration) -> String {
if !productParameters.isEmpty {
url += urlProductParameters()
}
if let autoTrackingParameters = config.onQueueAutoTrackParameters {
url += autoTrackingParameters
}
if let crossDeviceParameters = config.crossDeviceParameters {
url += crossDeviceParameters
}
url += "&\(ParameterName.EndOfRequest.rawValue)"
return url
}
*/

/* media 
public func urlWithAllParameter(config: TrackerConfiguration) -> String {
if let autoTrackingParameters = config.onQueueAutoTrackParameters {
url += autoTrackingParameters
}
if let crossDeviceParameters = config.crossDeviceParameters {
url += crossDeviceParameters
}
return url
}
*/

/* page 
public func urlWithAllParameter(config: TrackerConfiguration) -> String {
if !productParameters.isEmpty {
url += urlProductParameters()
}
if let autoTrackingParameters = config.onQueueAutoTrackParameters {
url += autoTrackingParameters
}
if let crossDeviceParameters = config.crossDeviceParameters {
url += crossDeviceParameters
}
url += "&\(ParameterName.EndOfRequest.rawValue)"
return url
}
*/

extension ActionParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()
			queryItems.append(NSURLQueryItem(name: .ActionName, value: name))

			if !categories.isEmpty {
				for (index, value) in categories {
					queryItems.append(NSURLQueryItem(name: .ActionCategory, withIndex: index, value: value))
				}
			}

			if !session.isEmpty {
				for (index, value) in session {
					queryItems.append(NSURLQueryItem(name: .Session, withIndex: index, value: value))
				}
			}
			return queryItems
		}
	}
}


extension CustomerParameter: Parameter {
	private var birthdayFormatter: NSDateFormatter {
		get {
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyyMMdd"
			return formatter
		}
	}

	internal var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()
			var categories = self.categories

			if let value = eMail.isEmpty ? categories.keys.contains(700) ? categories[700] : nil : eMail where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerEmail, value: value))
			}
			categories.removeValueForKey(700)

			if let value = eMailReceiverId.isEmpty ? categories.keys.contains(701) ? categories[701] : nil : eMailReceiverId  where !value.isEmpty{
				queryItems.append(NSURLQueryItem(name: .CustomerEmailReceiver, value: value))
			}
			categories.removeValueForKey(701)

			if let value = newsletter {
				queryItems.append(NSURLQueryItem(name: .CustomerNewsletter, value: value ? "1" : "2"))
			} else if let value = categories[702] where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerNewsletter, value: value))
			}
			categories.removeValueForKey(702)

			if let value = firstName.isEmpty ? categories.keys.contains(703) ? categories[703] : nil : firstName where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerFirstName, value: value))
			}
			categories.removeValueForKey(703)

			if let value = lastName.isEmpty ? categories.keys.contains(704) ? categories[704] : nil : lastName where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerLastName, value: value))
			}
			categories.removeValueForKey(704)

			if let value = phoneNumber.isEmpty ? categories.keys.contains(705) ? categories[705] : nil : phoneNumber where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerPhoneNumber, value: value))
			}
			categories.removeValueForKey(705)

			if let value = gender {
				queryItems.append(NSURLQueryItem(name: .CustomerGender, value: value.toValue()))
			} else if let value = categories[706] where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerGender, value: value))
			}
			categories.removeValueForKey(706)

			if let value = birthday {
				queryItems.append(NSURLQueryItem(name: .CustomerBirthday, value: birthdayFormatter.stringFromDate(value)))
			} else if let value = categories[707] where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerBirthday, value: value))
			}
			categories.removeValueForKey(707)

			if let value = city.isEmpty ? categories.keys.contains(708) ? categories[708] : nil : city where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerCity, value: value))
			}
			categories.removeValueForKey(708)

			if let value = country.isEmpty ? categories.keys.contains(709) ? categories[709] : nil : country where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerCountry, value: value))
			}
			categories.removeValueForKey(709)

			if let value = zip.isEmpty ? categories.keys.contains(710) ? categories[710] : nil : zip where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerZip, value: value))
			}
			categories.removeValueForKey(710)

			if let value = street.isEmpty ? categories.keys.contains(711) ? categories[711] : nil : street where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerStreet, value: value))
			}
			categories.removeValueForKey(711)

			if let value = streetNumber.isEmpty ? categories.keys.contains(712) ? categories[712] : nil : streetNumber where !value.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerStreetNumber, value: value))
			}
			categories.removeValueForKey(712)

			if !number.isEmpty {
				queryItems.append(NSURLQueryItem(name: .CustomerNumber, value: number))
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					queryItems.append(NSURLQueryItem(name: .CustomerCategory, withIndex: index, value: value))
				}
			}
			return queryItems
		}
	}
}

internal extension CustomerGender {
	internal func toValue() -> String {
		switch self {
		case .Male:
			return "1"
		case .Female:
			return "2"
		}
	}


	internal static func from(value: String) -> CustomerGender? {
		switch value {
		case "1":
			return .Male
		case "2":
			return .Female
		default:
			return nil
		}
	}
}


extension EcommerceParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()
			if !currency.isEmpty {
				queryItems.append(NSURLQueryItem(name: .EcomCurrency, value: currency))
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					queryItems.append(NSURLQueryItem(name: .EcomCategory, withIndex: index, value: value))
				}
			}

			if !orderNumber.isEmpty {
				queryItems.append(NSURLQueryItem(name: .EcomOrderNumber, value: orderNumber))
			}

			queryItems.append(NSURLQueryItem(name: .EcomStatus, value: status.rawValue))

			queryItems.append(NSURLQueryItem(name: .EcomTotalValue, value: "\(totalValue)"))

			if let voucherValue = voucherValue {
				queryItems.append(NSURLQueryItem(name: .EcomVoucherValue, value: "\(voucherValue)"))
			}

			return queryItems
		}
	}
}


extension GeneralParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
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


extension MediaParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()
			queryItems.append(NSURLQueryItem(name: .MediaName, value: name))

			queryItems.append(NSURLQueryItem(name: .MediaAction, value: action.rawValue))
			queryItems.append(NSURLQueryItem(name: .MediaPosition, value: "\(position)"))
			queryItems.append(NSURLQueryItem(name: .MediaDuration, value: "\(duration)"))
			queryItems.append(NSURLQueryItem(name: .MediaTimeStamp, value: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))

			if let bandwidth = bandwidth {
				queryItems.append(NSURLQueryItem(name: .MediaBandwidth, value: "\(bandwidth)"))
			}

			if let mute = mute {
				queryItems.append(NSURLQueryItem(name: .MediaMute, value: mute ? "1" : "0"))
			}

			if let volume = volume {
				queryItems.append(NSURLQueryItem(name: .MediaVolume, value: "\(volume)"))
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					queryItems.append(NSURLQueryItem(name: .MediaCategories, withIndex: index, value: value))
				}
			}

			return queryItems
		}
	}
}


extension PageParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
		get {
			var queryItems = [NSURLQueryItem]()

			if !page.isEmpty {
				for (index, value) in page {
					queryItems.append(NSURLQueryItem(name: .Page, withIndex: index, value: value))
				}
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					queryItems.append(NSURLQueryItem(name: .PageCategory, withIndex: index, value: value))
				}
			}

			if !session.isEmpty {
				for (index, value) in session {
					queryItems.append(NSURLQueryItem(name: .Session, withIndex: index, value: value))
				}
			}

			return queryItems
		}
	}
}


extension PixelParameter: Parameter {
	internal var urlParameter: [NSURLQueryItem] {
		get {
			return [NSURLQueryItem(name: .Pixel, value: "\(version),\(pageName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(Int64(timeStamp.timeIntervalSince1970 * 1000)),0,0,0")]
		}
	}
}

internal extension CrossDeviceBridgeParameter {
	internal func toParameter() -> String {
		var result = ""
		for item in [email, phone, address, facebook, twitter, googlePlus, linkedIn] {
			guard let item = item else {
				continue
			}
			result += item.toParameter()
		}
		return result
	}
}


internal extension CrossDeviceBridgeAttributes {
	internal func toParameter() -> String {
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
			return "&\(ParameterName.urlParameter(fromName: ParameterName.CdbFacebook, andValue: id))"
		case .Twitter(let id):
			return "&\(ParameterName.urlParameter(fromName: ParameterName.CdbTwitter, andValue: id))"
		case .GooglePlus(let id):
			return "&\(ParameterName.urlParameter(fromName: ParameterName.CdbGooglePlus, andValue: id))"
		case .LinkedIn(let id):
			return "&\(ParameterName.urlParameter(fromName: ParameterName.CdbLinkedIn, andValue: id))"
		}
	}


	private func encodeToParameter(plain plain: String?, md5: String?, md5Key: ParameterName, sha256: String?, sha256Key: ParameterName, normalizer: (String) -> String) -> String {
		var result = ""
		if let plain = plain {
			// computate md5 and sha256
			let text = normalizer(plain)
			result += "&\(ParameterName.urlParameter(fromName: md5Key, andValue: "\(self.md5(text))"))"
			result += "&\(ParameterName.urlParameter(fromName: sha256Key, andValue: "\(self.sha256(text))"))"
		}
		else {
			// add if not nil
			if let md5 = md5 {
				result += "&\(ParameterName.urlParameter(fromName: md5Key, andValue: md5))"
			}
			if let sha256 = sha256 {
				result += "&\(ParameterName.urlParameter(fromName: sha256Key, andValue: sha256))"
			}
		}
		return result
	}


	private func md5(string: String) -> String{
		return string.md5()
	}
	
	
	private func sha256(string: String) -> String{
		return string.sha256()
	}
}
