/** Enhance tracking by adding properties to track users across different devices. */
public struct CrossDeviceProperties {

	public var address: HashableTrackingValue<Address>?
	public var emailAddress: HashableTrackingValue<String>?
	public var facebookId: String?
	public var googlePlusId: String?
	public var linkedInId: String?
	public var phoneNumber: HashableTrackingValue<String>?
	public var twitterId: String?


	public init(
		address: HashableTrackingValue<Address>? = nil,
		emailAddress: HashableTrackingValue<String>? = nil,
		facebookId: String? = nil,
		googlePlusId: String? = nil,
		linkedInId: String? = nil,
		phoneNumber: HashableTrackingValue<String>? = nil,
		twitterId: String? = nil
	) {
		self.address = address
		self.emailAddress = emailAddress
		self.facebookId = facebookId
		self.googlePlusId = googlePlusId
		self.linkedInId = linkedInId
		self.twitterId = twitterId
	}



	public struct Address {

		public var firstName: String?
		public var lastName: String?
		public var street: String?
		public var streetNumber: String?
		public var zipCode: String?


		public init(
			firstName: String? = nil,
			lastName: String? = nil,
			street: String? = nil,
			streetNumber: String? = nil,
			zipCode: String? = nil
		) {
			self.firstName = firstName
			self.lastName = lastName
			self.street = street
			self.streetNumber = streetNumber
			self.zipCode = zipCode
		}
	}
}
