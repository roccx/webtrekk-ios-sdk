//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//


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
