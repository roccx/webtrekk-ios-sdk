import UIKit

public struct PageTrackingParameter: TrackingParameter{
	public var customParameters:   [String: String]
	public var customerParameter:  CustomerParameter?
	public var ecommerceParameter: EcommerceParameter?
	public var generalParameter:   GeneralParameter
	public var pageParameter:      PageParameter
	public var pixelParameter:     PixelParameter
	public var productParameters:  [ProductParameter]

	public init(pageName: String = "", pageParameter: PageParameter = PageParameter(), customParameters: [String: String] = [:], customerParameter: CustomerParameter? = nil, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = []) {

		let timeStamp = NSDate()
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.customParameters = customParameters
		self.customerParameter = customerParameter
		self.pageParameter = pageParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		if pageName.isEmpty {
			self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		}
		else {
			self.pixelParameter = PixelParameter(pageName: pageName, displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		}
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}

	
	public func urlWithAllParameter(config: TrackerConfiguration) -> String {
		var url = config.baseUrl.absoluteString
		url += pixelParameter.urlParameter
		url += generalParameter.urlParameter
		if !pageParameter.urlParameter.isEmpty {
			url += pageParameter.urlParameter
		}
		if !productParameters.isEmpty {
			url += urlProductParameters()
		}
		if let ecommerceParameter = ecommerceParameter {
			url += ecommerceParameter.urlParameter
		}
		if !customParameters.isEmpty {
			for (key, value) in customParameters {
				url += "&\(key)=\(value)"
			}
		}
		return url
	}
}