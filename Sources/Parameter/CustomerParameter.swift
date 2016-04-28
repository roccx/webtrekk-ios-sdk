import Foundation

public struct CustomerParameter {

	public var birthday:        NSDate?
	public var categories:      [Int: String]
	public var city:            String
	public var country:         String
	public var eMail:           String
	public var eMailReceiverId: String
	public var gender:          CustomerGender?
	public var firstName:       String
	public var lastName:        String
	public var newsletter:      Bool?
	public var number:          String
	public var phoneNumber:     String
	public var street:          String
	public var streetNumber:    String
	public var zip:             String

	public init(birthday: NSDate? = nil, categories: [Int: String] = [Int: String](), city: String = "", country: String = "", eMail: String = "", eMailReceiverId: String = "", firstName: String = "", gender: CustomerGender? = nil, lastName: String = "", newsletter: Bool? = nil, number: String = "", phoneNumber: String = "", street: String = "", streetNumber: String = "", zip: String = "") {
		self.birthday = birthday
		self.categories = categories
		self.city = city
		self.country = country
		self.eMail = eMail
		self.eMailReceiverId = eMailReceiverId
		self.firstName = firstName
		self.gender = gender
		self.lastName = lastName
		self.newsletter	= newsletter
		self.number = number
		self.phoneNumber = phoneNumber
		self.street = street
		self.streetNumber = streetNumber
		self.zip = zip
	}
}

public enum CustomerGender {
	case Male
	case Female
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