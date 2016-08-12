import Foundation


public struct UserProperties {

	public var birthday: Birthday?
	public var city: String?
	public var country: String?
	public var details: [Int: TrackingValue]?
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
    var emailAddressConfig: PropertyValue?
    var emailReceiverIdConfig: PropertyValue?
    var birthdayConfig: PropertyValue?
    var genderConfig: PropertyValue?
    var idConfig: PropertyValue?
    

    public init(
        birthday: Birthday? = nil,
        city: String? = nil,
        country: String? = nil,
        details: [Int: TrackingValue]? = nil,
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
        self.city = city
        self.country = country
        self.details = details
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
    
    
 	init(
		birthdayConfig: PropertyValue? = nil,
		city: String? = nil,
		country: String? = nil,
		details: [Int: TrackingValue]? = nil,
		emailAddressConfig: PropertyValue? = nil,
		emailReceiverIdConfig: PropertyValue? = nil,
		firstName: String? = nil,
		genderConfig: PropertyValue? = nil,
		idConfig: PropertyValue? = nil,
		lastName: String? = nil,
		newsletterSubscribed: Bool? = nil,
		phoneNumber: String? = nil,
		street: String? = nil,
		streetNumber: String? = nil,
		zipCode: String? = nil
	) {
		self.birthdayConfig = birthdayConfig
		self.city = city
		self.country = country
		self.details = details
		self.emailAddressConfig = emailAddressConfig
		self.emailReceiverIdConfig = emailReceiverIdConfig
		self.firstName = firstName
		self.genderConfig = genderConfig
		self.idConfig = idConfig
		self.lastName = lastName
		self.newsletterSubscribed = newsletterSubscribed
		self.phoneNumber = phoneNumber
		self.street = street
		self.streetNumber = streetNumber
		self.zipCode = zipCode
	}
    
	@warn_unused_result
	internal func merged(over other: UserProperties) -> UserProperties {
		 var new = UserProperties(
			birthday:             birthday ?? other.birthday,
			city:                 city ?? other.city,
			country:              country ?? other.country,
			details:              details.merged(over: other.details),
			emailAddress:         emailAddress ?? other.emailAddress,
			emailReceiverId:      emailReceiverId ?? other.emailReceiverId,
			firstName:            firstName ?? other.firstName,
			gender:               gender ?? other.gender,
			id:                   id ?? other.id,
			lastName:             lastName ?? other.lastName,
			newsletterSubscribed: newsletterSubscribed ?? other.newsletterSubscribed,
			phoneNumber:          phoneNumber ?? other.phoneNumber,
			street:               street ?? other.street,
			streetNumber:         streetNumber ?? other.streetNumber,
			zipCode:              zipCode ?? other.zipCode
		)
        
        new.birthdayConfig = birthdayConfig ?? other.birthdayConfig
        new.emailAddressConfig = emailAddressConfig ?? other.emailAddressConfig
        new.emailReceiverIdConfig = emailReceiverIdConfig ?? other.emailReceiverIdConfig
        new.genderConfig = genderConfig ?? other.genderConfig
        new.idConfig = idConfig ?? other.idConfig
        return new
	}



	public struct Birthday {

		public var day: Int
		public var month: Int
		public var year: Int

		public init(day: Int = 1, month: Int, year: Int) {
			self.day = day
			self.month = month
			self.year = year
		}
        
        init?(raw: String?)
        {
            guard let rawValue = raw else{
                return nil
            }

            if (rawValue.isBirthday)
            {
                self.year = Int(rawValue.substringWithRange(rawValue.startIndex...rawValue.startIndex.advancedBy(3)))!
                self.month = Int(rawValue.substringWithRange(rawValue.startIndex.advancedBy(4)...rawValue.startIndex.advancedBy(5)))!
                self.day = Int(rawValue.substringWithRange(rawValue.startIndex.advancedBy(6)..<rawValue.endIndex))!
            }else{
                WebtrekkTracking.logger.logWarning("Incorrect bithday format. Birthday won't be tracked")
                return nil
            }
        }
	}
	
    public enum Gender: Int {
        case male = 1
		case female
        case unknown
        
        init?(raw: String?){
            
            guard let rawValue = raw else{
                return nil
            }
            
            if rawValue.isGender {
                self = Gender(rawValue: Int(rawValue)!)!
            }else{
                WebtrekkTracking.logger.logWarning("Incorrect gender format. Gender won't be tracked")
                return nil
            }
        }
 	}
    
    
    mutating func processKeys(event: TrackingEvent){
        if let birthday = Birthday(raw: birthdayConfig?.serialized(for: event)) {
            self.birthday = birthday
        }
        if let emailAddress = emailAddressConfig?.serialized(for: event) {
            self.emailAddress = emailAddress
        }
        if let emailReceiverId = emailReceiverIdConfig?.serialized(for: event) {
            self.emailReceiverId = emailReceiverId
        }
        if let id = idConfig?.serialized(for: event) {
            self.id = id
        }
        if let gender = Gender(raw: genderConfig?.serialized(for: event)) {
            self.gender = gender
        }
    }

}

private extension String  {
    var isBirthday : Bool {
        get{
            return characters.count == 8 && self.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) == nil
        }
    }
    
    var isGender: Bool {
        get{
            return characters.count == 1 && (self == "1" || self == "2" || self == "3")
        }
    }
}
