import Foundation
import CryptoSwift

public struct CrossDeviceBridgeParameter {
	public var email: CrossDeviceBridgeAttributes? {
		didSet {
			guard let email = email,  case .Email = email else {
				self.email = nil
				return
			}
		}
	}
	public var phone: CrossDeviceBridgeAttributes? {
		didSet {
			guard let phone = phone,  case .Phone = phone else {
				self.phone = nil
				return
			}
		}
	}
	public var address: CrossDeviceBridgeAttributes? {
		didSet {
			guard let address = address,  case .Address = address else {
				self.address = nil
				return
			}
		}
	}
	public var facebook: CrossDeviceBridgeAttributes? {
		didSet {
			guard let facebook = facebook,  case .Facebook = facebook else {
				self.facebook = nil
				return
			}
		}
	}
	public var twitter: CrossDeviceBridgeAttributes? {
		didSet {
			guard let twitter = twitter,  case .Twitter = twitter else {
				self.twitter = nil
				return
			}
		}
	}
	public var googlePlus: CrossDeviceBridgeAttributes? {
		didSet {
			guard let googlePlus = googlePlus,  case .GooglePlus = googlePlus else {
				self.googlePlus = nil
				return
			}
		}
	}
	public var linkedIn: CrossDeviceBridgeAttributes? {
		didSet {
			guard let linkedIn = linkedIn,  case .LinkedIn = linkedIn else {
				self.linkedIn = nil
				return
			}
		}
	}

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


public enum CrossDeviceBridgeAttributes{
	case Email(plain: String?, md5: String?, sha256: String?)
	case Phone(plain: String?, md5: String?, sha256: String?)
	case Address(plain: AddressContainer?, md5: String?, sha256: String?)
	case Facebook(id: String)
	case Twitter(id: String)
	case GooglePlus(id: String)
	case LinkedIn(id: String)

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


	public struct AddressContainer {
		var lastName: String
		var firstName: String
		var zip: String
		var street: String
		var streetNumber: String

		internal func toLine() -> String {
			return "\(lastName)|\(firstName)|\(zip)|\(street)|\(streetNumber)"
		}
	}
}