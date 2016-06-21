import Foundation


public struct UserProperties {

	public var birthday: NSDate?
	public var categories: Set<Category> = []
	public var city: String?
	public var country: String?
	public var eMail: String?
	public var eMailReceiverId: String?
	public var gender: Gender?
	public var firstName: String?
	public var lastName: String?
	public var newsletter: Bool?
	public var number: String?
	public var phoneNumber: String?
	public var street: String?
	public var streetNumber: String?
	public var zip: String?


	public init() {}



	public enum Gender {

		case female
		case male
	}
}
