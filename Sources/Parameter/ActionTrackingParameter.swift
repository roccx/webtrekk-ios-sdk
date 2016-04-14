import UIKit

public struct ActionTrackingParameter: TrackingParameter {
	public var actionParameter:    ActionParameter
	public var customParameters:   [String: String]
	public var customerParameter:  CustomerParameter?
	public var ecommerceParameter: EcommerceParameter?
	public var generalParameter:   GeneralParameter
	public var pixelParameter:     PixelParameter
	public var productParameters:  [ProductParameter]

	public init(actionParameter: ActionParameter, customParameters: [String: String] = [:], customerParameter: CustomerParameter? = nil, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = []) {

		let timeStamp = NSDate()
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self.actionParameter = actionParameter
		self.customParameters = customParameters
		self.customerParameter = customerParameter
		self.ecommerceParameter = ecommerceParameter
		self.productParameters = productParameters
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}
	
	public func urlWithAllParameter(config: TrackerConfiguration) -> String {
		var url = config.baseUrl.absoluteString
		url += pixelParameter.urlParameter
		url += generalParameter.urlParameter
		if !actionParameter.urlParameter.isEmpty {
			url += actionParameter.urlParameter
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