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