import UIKit

public struct ActionTrackingParameter: TrackingParameter {
	public var generalParameter: GeneralParameter
	public var pixelParameter:   PixelParameter

	public var customParameters:   [String: String]
	public var customerParameter:  CustomerParameter?
	public var ecommerceParameter: EcommerceParameter?
	public var productParameters:  [ProductParameter]

	private var _actionParameter:   ActionParameter
	public var actionParameter:     ActionParameter? {
		set { guard let actionParameter = newValue else {
			return
			}
			self._actionParameter = actionParameter
		}
		get { return self._actionParameter }
	}
	public var mediaParameter:    MediaParameter? {
		set {}
		get { return nil }
	}
	public var pageParameter:      PageParameter? {
		set {}
		get { return nil }
	}

	public init(actionParameter: ActionParameter, customParameters: [String: String] = [:], customerParameter: CustomerParameter? = nil, ecommerceParameter: EcommerceParameter? = nil, productParameters: [ProductParameter] = []) {

		let timeStamp = NSDate()
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60
		self._actionParameter = actionParameter
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
		if !_actionParameter.urlParameter.isEmpty {
			url += _actionParameter.urlParameter
		}
		if !productParameters.isEmpty {
			url += urlProductParameters()
		}
		if let ecommerceParameter = ecommerceParameter {
			url += ecommerceParameter.urlParameter
		}
		if !customParameters.isEmpty {
			for (key, value) in customParameters {
				url += "&\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
			}
		}
		if let autoTrackingParameters = config.onQueueAutoTrackParameters {
			url += autoTrackingParameters
		}
		if let crossDeviceParameters = config.crossDeviceParameters {
			url += crossDeviceParameters
		}
		return url
	}
}