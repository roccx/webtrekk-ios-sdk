import UIKit

public struct PageTracking: TrackingParameter{
	public var generalParameter: GeneralParameter
	public var pixelParameter:   PixelParameter

	public var customParameters:   [String: String]
	public var customerParameter:  CustomerParameter?
	public var ecommerceParameter: EcommerceParameter?
	public var productParameters:  [ProductParameter]

	private var _pageParameter:   PageParameter
	public var pageParameter:     PageParameter? {
		set { guard let pageParameter = newValue else {
			return
			}
			self._pageParameter = pageParameter
		}
		get { return self._pageParameter }
	}
	public var mediaParameter:    MediaParameter? {
		set {}
		get { return nil }
	}
	public var actionParameter:      ActionParameter? {
		set {}
		get { return nil }
	}

	public init(pageName: String, pageParameter: PageParameter = PageParameter(), customParameters: [String: String] = [:], customerParameter: CustomerParameter? = nil, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = []) {

		let timeStamp = NSDate()
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.customParameters = customParameters
		self.customerParameter = customerParameter
		self._pageParameter = pageParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(pageName: pageName, displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}
}