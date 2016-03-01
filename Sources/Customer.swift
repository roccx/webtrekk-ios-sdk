import Foundation

public struct Customer {

	public var categories      = [Int: String]()
	public var city            = ""
	public var country         = ""
	public var eMail           = ""
	public var eMailRecieverId = ""
	public var firstName       = ""
	public var lastName        = ""
	public var number          = ""
	public var phoneNumber     = ""
	public var street          = ""
	public var streetNumber    = ""
	public var zip             = ""


	private var gender                      = 0
	private var newsletterSubscriptionValue = 0

	public init() {
	}

	public var birthday: String = "" {
		didSet{
		guard oldValue != birthday else {
			return
		}

		guard birthday.characters.count == 8 else {
			fatalError("birthday needs to be formated as yyyymmdd")
		}
		}
	}


	public var female: Bool? {
		didSet{
		guard oldValue != female else {
			return
		}
		if let value = female {
			male = nil
			gender = value ? 2 : 1
		} else {
			gender = 0
		}
		}
	}


	public var male: Bool? {
		didSet{
		guard oldValue != male else {
			return
		}
		if let value = male {
			female = nil
			gender = value ? 1 : 2
		} else {
			gender = 0
		}
		}
	}

	public var newsletterSubscription: Bool? {
		didSet{
		guard oldValue != newsletterSubscription else {
			return
		}
		if let value = newsletterSubscription {
			newsletterSubscriptionValue = value ? 1 : 2
		} else {
			newsletterSubscriptionValue = 0
		}
		}
	}

}


public struct CustomerParameter{
	public private(set) var customer: Customer

	public init(customer: Customer) {
		self.customer = customer
	}
}
