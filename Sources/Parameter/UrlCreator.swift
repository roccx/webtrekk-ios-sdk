import Foundation

extension ActionParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = "&\(ParameterName.urlParameter(fromName: .ActionName, andValue: name))"

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .ActionCategory, withIndex: index, andValue: value))"
				}
			}

			if !session.isEmpty {
				for (index, value) in session {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .Session, withIndex: index, andValue: value))"
				}
			}
			return urlParameter
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

	internal var urlParameter: String {
		get {
			var urlParameter = ""
			var categories = self.categories

			if let value = eMail.isEmpty ? categories.keys.contains(700) ? categories[700] : nil : eMail where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerEmail, andValue: value))"
			}
			categories.removeValueForKey(700)

			if let value = eMailReceiverId.isEmpty ? categories.keys.contains(701) ? categories[701] : nil : eMailReceiverId  where !value.isEmpty{
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerEmailReceiver, andValue: value))"
			}
			categories.removeValueForKey(701)

			if let value = newsletter {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerNewsletter, andValue: value ? "1" : "2"))"
			} else if let value = categories[702] where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerNewsletter, andValue: value))"
			}
			categories.removeValueForKey(702)

			if let value = firstName.isEmpty ? categories.keys.contains(703) ? categories[703] : nil : firstName where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerFirstName, andValue: value))"
			}
			categories.removeValueForKey(703)

			if let value = lastName.isEmpty ? categories.keys.contains(704) ? categories[704] : nil : lastName where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerLastName, andValue: value))"
			}
			categories.removeValueForKey(704)

			if let value = phoneNumber.isEmpty ? categories.keys.contains(705) ? categories[705] : nil : phoneNumber where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerPhoneNumber, andValue: value))"
			}
			categories.removeValueForKey(705)

			if let value = gender {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerGender, andValue: "\(value.toValue())"))"
			} else if let value = categories[706] where !value.isEmpty {

			}
			categories.removeValueForKey(706)

			if let value = birthday {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: birthdayFormatter.stringFromDate(value)))"
			} else if let value = categories[707] where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerBirthday, andValue: value))"
			}
			categories.removeValueForKey(707)

			if let value = city.isEmpty ? categories.keys.contains(708) ? categories[708] : nil : city where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerCity, andValue: value))"
			}
			categories.removeValueForKey(708)

			if let value = country.isEmpty ? categories.keys.contains(709) ? categories[709] : nil : country where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerCountry, andValue: value))"
			}
			categories.removeValueForKey(709)

			if let value = zip.isEmpty ? categories.keys.contains(710) ? categories[710] : nil : zip where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerZip, andValue: value))"
			}
			categories.removeValueForKey(710)

			if let value = street.isEmpty ? categories.keys.contains(711) ? categories[711] : nil : street where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerStreet, andValue: value))"
			}
			categories.removeValueForKey(711)

			if let value = streetNumber.isEmpty ? categories.keys.contains(712) ? categories[712] : nil : streetNumber where !value.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerStreetNumber, andValue: value))"
			}
			categories.removeValueForKey(712)

			if !number.isEmpty {
				urlParameter = "&\(ParameterName.urlParameter(fromName: .CustomerNumber, andValue: number))"
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .CustomerCategory, withIndex: index, andValue: value))"
				}
			}
			return urlParameter
		}
	}
}

internal extension CustomerGender {
	internal func toValue() -> Int {
		switch self {
		case .Male:
			return 1
		case .Female:
			return 2
		}
	}


	internal static func from(value: Int) -> CustomerGender? {
		switch value {
		case 1:
			return .Male
		case 2:
			return .Female
		default:
			return nil
		}
	}
}


extension EcommerceParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = ""
			if !currency.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomCurrency, andValue: currency))"
			}
			if !categories.isEmpty {
				for (index, value) in categories {

					urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomCategory, withIndex: index, andValue: value))"
				}
			}

			if !orderNumber.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomOrderNumber, andValue: orderNumber))"
			}

			urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomStatus, andValue: status.rawValue))"

			urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomTotalValue, andValue: "\(totalValue)"))"

			if let voucherValue = voucherValue {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomVoucherValue, andValue: "\(voucherValue)"))"
			}

			return urlParameter
		}
	}
}


extension GeneralParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = "&\(ParameterName.urlParameter(fromName: .EverId, andValue: everId))"
			if firstStart {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .FirstStart, andValue: "1"))"
			}
			if !ip.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .IpAddress, andValue: ip))"
			}
			if !nationalCode.isEmpty {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .NationalCode, andValue: nationalCode))"
			}
			urlParameter += "&\(ParameterName.urlParameter(fromName: .SamplingRate, andValue: "\(samplingRate)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .TimeStamp, andValue: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .TimeZoneOffset, andValue: "\(timeZoneOffset)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .UserAgent, andValue: userAgent))"

			return urlParameter
		}
	}
}


extension MediaParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = "&\(ParameterName.urlParameter(fromName: .MediaName, andValue: name))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaAction, andValue: action.rawValue))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaPosition, andValue: "\(position)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaDuration, andValue: "\(duration)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaTimeStamp, andValue: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))"

			if let bandwidth = bandwidth {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaBandwidth, andValue: "\(bandwidth)"))"
			}

			if let mute = mute {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaMute, andValue: mute ? "1" : "0"))"
			}

			if let volume = volume {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaVolume, andValue: "\(volume)"))"
			}

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaCategories, withIndex: index, andValue: value))"
				}
			}

			return urlParameter
		}
	}
}


extension PageParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = ""

			if !page.isEmpty {
				for (index, value) in page {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .Page, withIndex: index, andValue: value))"
				}


			}

			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .PageCategory, withIndex: index, andValue: value))"
				}
			}

			if !session.isEmpty {
				for (index, value) in session {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .Session, withIndex: index, andValue: value))"
				}
			}

			return urlParameter
		}
	}
}


extension PixelParameter: Parameter {
	internal var urlParameter: String {
		get {
			return "?\(ParameterName.Pixel.rawValue)=\(version),\(pageName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(Int64(timeStamp.timeIntervalSince1970 * 1000)),0,0,0"
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
