import Foundation



public struct ActionTrackingEvent {

	public var actionProperties: ActionProperties
	public var ecommerceProperties: EcommerceProperties?
	public var userProperties: UserProperties?

	public init(actionProperties: ActionProperties) {
		self.actionProperties = actionProperties

	}
}


public struct ActionProperties {

	public var name: String
	public var session: Set<Category> = []
	public var category: Set<Category> = []


	public init(name: String) {
		self.name = name
	}

}


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
		case Male
		case Female
	}
}


public struct EcommerceProperties {
	public var currency: String?
	public var categories: Set<Category> = []
	public var orderNumber: String?
	public var status: Status
	public var totalValue: Double
	public var voucherValue: Double?


	public init(totalValue: Double, status: Status = .view) {
		self.status = status
		self.totalValue = totalValue
	}


	public enum Status: String {
		case add
		case conf
		case view
	}
}