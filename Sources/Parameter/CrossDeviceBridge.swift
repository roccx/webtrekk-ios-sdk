import Foundation
import CryptoSwift

public struct CrossDeviceBridgeParameter {
	public var attributes:      [CrossDeviceBridgeAttributes]

}

public enum CrossDeviceBridgeAttributes{
	case Email(plain: String?, md5: String?, sha256: String?)
	case Phone(plain: String?, md5: String?, sha256: String?)
	case Address(plain: String?, md5: String?, sha256: String?)
	case Facebook(id: String)
	case Twitter(id: String)
	case GooglePlus(id: String)
	case LinkedIn(id: String)

	public func toParameter() -> String {
		switch self {
		case .Email(let plain, let md5, let sha256):
			return encodeToParameter(plain: plain, md5: md5, md5Key: .CdbEmailMd5, sha256: sha256, sha256Key: .CdbEmailSha256) { text in
				return text.lowercaseString
			}
		case .Phone(let plain, let md5, let sha256):
			return encodeToParameter(plain: plain, md5: md5, md5Key: .CdbPhoneMd5, sha256: sha256, sha256Key: .CdbPhoneSha256) { text in
				return text.lowercaseString
			}
		case .Address(let plain, let md5, let sha256):
			return encodeToParameter(plain: plain, md5: md5, md5Key: .CdbAddressMd5, sha256: sha256, sha256Key: .CdbAddressSha256) { text in
				return text.lowercaseString
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
		//		var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//		if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//			CC_MD5(data.bytes, UInt32(data.length), &digest)
//		}
//
//		return digest
	}

	private func sha256(string: String) -> String{
		return string.sha256()
//		var digest = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
//		if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//			CC_SHA256(data.bytes, UInt32(data.length), &digest)
//		}
//
//		return digest
	}
}