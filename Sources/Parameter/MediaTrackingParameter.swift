import UIKit

public struct MediaTrackingParameter: TrackingParameter {
	public var generalParameter: GeneralParameter
	public var pixelParameter:   PixelParameter

	public var customParameters:   [String: String]
	public var customerParameter:  CustomerParameter?
	public var ecommerceParameter: EcommerceParameter?
	public var productParameters:  [ProductParameter] {
		set {}
		get { return [] }
	}

	private var _mediaParameter: MediaParameter
	public var mediaParameter:     MediaParameter? {
		set { guard let mediaParameter = newValue else {
				return
			}
			self._mediaParameter = mediaParameter
		}
		get { return self._mediaParameter }
	}
	public var actionParameter:    ActionParameter? {
		set {}
		get { return nil }
	}
	public var pageParameter:      PageParameter? {
		set {}
		get { return nil }
	}



	public init(customParameters: [String: String] = [:], mediaParameter: MediaParameter) {

		let timeStamp = mediaParameter.timeStamp
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60

		self.customParameters = customParameters
		self._mediaParameter = mediaParameter
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}

	public func urlWithAllParameter(config: TrackerConfiguration) -> String {
		var url = config.baseUrl.absoluteString
		url += pixelParameter.urlParameter
		url += generalParameter.urlParameter
		url += _mediaParameter.urlParameter
		if !customParameters.isEmpty {
			for (key, value) in customParameters {
				url += "&\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
			}
		}
		if let autoTrackingParameters = config.onQueueAutoTrackParameters {
			url += autoTrackingParameters
		}
		return url
	}
}