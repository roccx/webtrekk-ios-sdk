import UIKit

public struct MediaTrackingParameter: BasicTrackingParameter {
	public var customParameters:   [String: String]
	public var generalParameter: GeneralParameter
	public var mediaParameter:   MediaParameter
	public var pixelParameter:   PixelParameter

	public init(customParameters: [String: String] = [:],mediaParameter: MediaParameter) {

		let timeStamp = mediaParameter.timeStamp
		let timeZoneOffset = Double(NSTimeZone.localTimeZone().secondsFromGMT * -1) / 60 / 60

		self.customParameters = customParameters
		self.mediaParameter = mediaParameter
		self.pixelParameter = PixelParameter(displaySize: UIScreen.mainScreen().bounds.size, timeStamp: timeStamp)
		self.generalParameter = GeneralParameter(timeStamp: timeStamp, timeZoneOffset: timeZoneOffset)
		generalParameter.everId = self.everId
		generalParameter.userAgent = userAgent
	}

	public func urlWithAllParameter(config: TrackerConfiguration) -> String {
		var url = config.baseUrl.absoluteString
		url += pixelParameter.urlParameter
		url += generalParameter.urlParameter
		url += mediaParameter.urlParameter
		if !customParameters.isEmpty {
			for (key, value) in customParameters {
				url += "&\(key)=\(value)"
			}
		}
		return url
	}
}