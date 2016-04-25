import Foundation

public struct CrossDeviceBridgeParameter {
	public var attributes:      [CrossDeviceBridge]

}

public enum CrossDeviceBridge{
	case Email(plain: String?, md5: String?, sha256: String?)
	case Phone(plain: String?, md5: String?, sha256: String?)
	case Address(plain: String?, md5: String?, sha256: String?)
	case Facebook(id: String)
	case Twitter(id: String)
	case GooglePlus(id: String)
	case LinkedIn(id: String)

	public func toParameter() {
		switch self {
		case .Email(let plain, let md5, let sha256):
			encodeToParameter(plain: plain, md5: md5, sha256: sha256) { text in
				return text.lowercaseString
			}
		case .Phone(let plain, let md5, let sha256):
			encodeToParameter(plain: plain, md5: md5, sha256: sha256) { text in
				return text.lowercaseString
			}
		case .Address(let plain, let md5, let sha256):
			encodeToParameter(plain: plain, md5: md5, sha256: sha256) { text in
				return text.lowercaseString
			}
		case .Facebook(let id):
			print(id)
		case .Twitter(let id):
			print(id)
		case .GooglePlus(let id):
			print(id)
		case .LinkedIn(let id):
			print(id)
		}
	}

	private func encodeToParameter(plain plain: String?, md5: String?, sha256: String?, normalizer: (String) -> String) -> String? {
		var result = ""
		if let plain = plain {
			// computate md5 and sha256
			let text = normalizer(plain)
			result += "&\("PARAMETER_NAME_MD5")=\(self.md5(text))"
			result += "&\("PARAMETER_NAME_SHA256")=\(self.sha256(text))"
		}
		else {
			// add if not nil
			if let md5 = md5 {
				result += "&\("PARAMETER_NAME_MD5")=\(md5)"
			}
			if let sha256 = sha256 {
				result += "&\("PARAMETER_NAME_MD5")=\(sha256)"
			}
		}
		return result.isEmpty ? nil : result
	}

	private func md5(string: String) -> [UInt8]{
		return [UInt8](count: Int(1), repeatedValue: 0)
	}

	private func sha256(string: String) -> [UInt8]{
		return [UInt8](count: Int(1), repeatedValue: 0)
	}
}


//public func md5(string string: String) -> [UInt8] {
//	var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
//	if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//		CC_MD5(data.bytes, UInt32(data.length), &digest)
//	}
//
//	return digest
//}
//
//public func sha256(string string: String) -> [UInt8] {
//	var digest = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
//	if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//		CC_SHA256(data.bytes, UInt32(data.length), &digest)
//	}
//
//	return digest
//}