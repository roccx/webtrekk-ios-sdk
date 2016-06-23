import Foundation


public struct UserProperties {

	public var birthday: NSDate?
	public var categories: Set<Category>?
	public var city: String?
	public var country: String?
	public var emailAddress: String?
	public var emailReceiverId: String?
	public var firstName: String?
	public var gender: Gender?
	public var id: String?
	public var lastName: String?
	public var newsletterSubscribed: Bool?
	public var phoneNumber: String?
	public var street: String?
	public var streetNumber: String?
	public var zipCode: String?


	public init(
		birthday: NSDate? = nil,
		categories: Set<Category>? = nil,
		city: String? = nil,
		country: String? = nil,
		emailAddress: String? = nil,
		emailReceiverId: String? = nil,
		firstName: String? = nil,
		gender: Gender? = nil,
		id: String? = nil,
		lastName: String? = nil,
		newsletterSubscribed: Bool? = nil,
		phoneNumber: String? = nil,
		street: String? = nil,
		streetNumber: String? = nil,
		zipCode: String? = nil
	) {
		self.birthday = birthday
		self.categories = categories
		self.city = city
		self.country = country
		self.emailAddress = emailAddress
		self.emailReceiverId = emailReceiverId
		self.firstName = firstName
		self.gender = gender
		self.id = id
		self.lastName = lastName
		self.newsletterSubscribed = newsletterSubscribed
		self.phoneNumber = phoneNumber
		self.street = street
		self.streetNumber = streetNumber
		self.zipCode = zipCode
	}
	


	public enum Gender {

		case female
		case male
	}
}
