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
}


public enum CrossDeviceBridgeAttributes{
	case Email(plain: String?, md5: String?, sha256: String?)
	case Phone(plain: String?, md5: String?, sha256: String?)
	case Address(plain: AddressContainer?, md5: String?, sha256: String?)
	case Facebook(id: String)
	case Twitter(id: String)
	case GooglePlus(id: String)
	case LinkedIn(id: String)

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