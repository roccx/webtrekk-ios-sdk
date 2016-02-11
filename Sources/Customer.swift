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


extension CustomerParameter: Parameter {


	public var queryItems: [NSURLQueryItem] {
		var queryItems = [NSURLQueryItem]()
		queryItems.append(NSURLQueryItem(name:"cd", value: customer.number))
		queryItems.append(NSURLQueryItem(name:"uc700", value: customer.eMail))
		queryItems.append(NSURLQueryItem(name:"uc701", value: customer.eMailRecieverId))
		queryItems.append(NSURLQueryItem(name:"uc702", value: "\(customer.newsletterSubscriptionValue == 0 ? "" : String(customer.newsletterSubscriptionValue))"))
		queryItems.append(NSURLQueryItem(name:"uc703", value: customer.firstName))
		queryItems.append(NSURLQueryItem(name:"uc704", value: customer.lastName))
		queryItems.append(NSURLQueryItem(name:"uc705", value: customer.phoneNumber))
		queryItems.append(NSURLQueryItem(name:"uc706", value: "\(customer.gender == 0 ? "" : String(customer.gender))"))
		queryItems.append(NSURLQueryItem(name:"uc707", value: "\(customer.birthday)"))
		queryItems.append(NSURLQueryItem(name:"uc708", value: customer.city))
		queryItems.append(NSURLQueryItem(name:"uc709", value: customer.country))
		queryItems.append(NSURLQueryItem(name:"uc710", value: customer.zip))
		queryItems.append(NSURLQueryItem(name:"uc711", value: customer.street))
		queryItems.append(NSURLQueryItem(name:"uc712", value: customer.streetNumber))
		for (index, value) in customer.categories {
			queryItems.append(NSURLQueryItem(name:"uc\(index)", value: value))
		}
		return queryItems.filter({!$0.value!.isEmpty})
	}
}