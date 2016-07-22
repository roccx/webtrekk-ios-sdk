/** Enhance tracking by adding properties to track users across different devices. */
public struct CrossDeviceProperties {

	public var address: AnonymizableValue<Address>?
	public var androidId: String?
	public var emailAddress: AnonymizableValue<String>?
	public var facebookId: String?
	public var googlePlusId: String?
	public var iosId: String?
	public var linkedInId: String?
	public var phoneNumber: AnonymizableValue<String>?
	public var twitterId: String?
	public var windowsId: String?


	public init(
		address: AnonymizableValue<Address>? = nil,
		androidId: String? = nil,
		emailAddress: AnonymizableValue<String>? = nil,
		facebookId: String? = nil,
		googlePlusId: String? = nil,
		iosId: String? = nil,
		linkedInId: String? = nil,
		phoneNumber: AnonymizableValue<String>? = nil,
		twitterId: String? = nil,
		windowsId: String? = nil
	) {
		self.address = address
		self.androidId = androidId
		self.emailAddress = emailAddress
		self.facebookId = facebookId
		self.googlePlusId = googlePlusId
		self.iosId = iosId
		self.linkedInId = linkedInId
		self.phoneNumber = phoneNumber
		self.twitterId = twitterId
		self.windowsId = windowsId
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

	@warn_unused_result
	internal func merged(over other: CrossDeviceProperties) -> CrossDeviceProperties {
		return CrossDeviceProperties(
			address:      address ?? other.address,
			androidId:    androidId ?? other.androidId,
			emailAddress: emailAddress ?? other.emailAddress,
			facebookId:   facebookId ?? other.facebookId,
			googlePlusId: googlePlusId ?? other.googlePlusId,
			iosId:        iosId ?? other.iosId,
			linkedInId:   linkedInId ?? other.linkedInId,
			phoneNumber:  phoneNumber ?? other.phoneNumber,
			twitterId:    twitterId ?? other.twitterId,
			windowsId:    windowsId ?? other.windowsId
		)
	}
}
