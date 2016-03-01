import Foundation
import SWXMLHash

internal class XmlConfigParser: ConfigParser {

	var trackerConfiguration: TrackerConfiguration {
		get {
			guard xml[.Root].boolValue else {
				fatalError("xml Root node not found")
			}
			guard xml[.Root][.TrackingDomain].boolValue && xml[.Root][.TrackId].boolValue, let serverUrl = xml[.Root][.TrackingDomain].element?.text, let trackingId = xml[.Root][.TrackId].element?.text else {
				fatalError("tracking domain and id needs to be set")
			}
			var config = TrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)

			if xml[.Root][.MaxRequests].boolValue, let maxRequests = Int((xml[.Root][.MaxRequests].element?.text)!) {
				config.maxRequests = maxRequests
			}
			if xml[.Root][.Sampling].boolValue, let Sampling = Int((xml[.Root][.Sampling].element?.text)!) {
				config.samplingRate = Sampling
			}
			if xml[.Root][.SendDelay].boolValue, let sendDelay = Int((xml[.Root][.SendDelay].element?.text)!) {
				config.sendDelay = sendDelay
			}
			if xml[.Root][.Version].boolValue, let version = Int((xml[.Root][.Version].element?.text)!) {
				config.version = version
			}

			if xml[.Root][.EnableRemoteConfiguration].boolValue {
				config.enableRemoteConfiguration = Bool((xml[.Root][.EnableRemoteConfiguration].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.TrackingConfigurationUrl].boolValue, let remoteConfigurationUrl = xml[.Root][.TrackingConfigurationUrl].element?.text {
				config.remoteConfigurationUrl = remoteConfigurationUrl
			}

			if xml[.Root][.AutoTracked].boolValue {
				config.autoTrack = Bool((xml[.Root][.AutoTracked].element?.text)!.lowercaseString == "true")
			}

			guard config.autoTrack else {
				return config
			}

			if xml[.Root][.AutoTrackAppUpdate].boolValue {
				config.autoTrackAppUpdate = Bool((xml[.Root][.AutoTrackAppUpdate].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackAppVersionName].boolValue {
				config.autoTrackAppVersionName = Bool((xml[.Root][.AutoTrackAppVersionName].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackAppVersionCode].boolValue {
				config.autoTrackAppVersionCode = Bool((xml[.Root][.AutoTrackAppVersionCode].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackApiLevel].boolValue {
				config.autoTrackApiLevel = Bool((xml[.Root][.AutoTrackApiLevel].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackScreenOrientation].boolValue {
				config.autoTrackScreenOrientation = Bool((xml[.Root][.AutoTrackScreenOrientation].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackConnectionType].boolValue {
				config.autoTrackConnectionType = Bool((xml[.Root][.AutoTrackConnectionType].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackRequestUrlStoreSize].boolValue {
				config.autoTrackRequestUrlStoreSize = Bool((xml[.Root][.AutoTrackRequestUrlStoreSize].element?.text)!.lowercaseString == "true")
			}
			if xml[.Root][.AutoTrackAdvertiserId].boolValue {
				config.autoTrackAdvertiserId = Bool((xml[.Root][.AutoTrackAdvertiserId].element?.text)!.lowercaseString == "true")
			}


			return config
		}
	}

	let xml: XMLIndexer

	internal init(xmlString: String) {
		guard !xmlString.isEmpty else {
			fatalError("xml String cannot be empty")
		}
		self.xml = SWXMLHash.parse(xmlString)
	}
}

internal enum XmlConfigParameter: String {
	case Root = "webtrekkConfiguration"

	// MARK: required parameters
	case TrackingDomain = "trackDomain"
	case TrackId = "trackId"

	// MARK: default parameters
	case MaxRequests = "maxRequests"
	case Sampling = "Sampling"
	case SendDelay = "sendDelay"
	case Version = "version"

	// MARK: auto parameters
	case AutoTracked = "autoTracked"
	case AutoTrackAppUpdate = "autoTrackAppUpdate"
	case AutoTrackAppVersionName = "autoTrackAppversionName"
	case AutoTrackAppVersionCode = "autoTrackAppversionCode"
	case AutoTrackApiLevel = "autoTrackApiLevel"
	case AutoTrackScreenOrientation = "autoTrackScreenOrientation"
	case AutoTrackConnectionType = "autoTrackConnectionType"
	case AutoTrackRequestUrlStoreSize = "autoTrackRequestUrlStoreSize"

	// MARK: advertiser id
	case AutoTrackAdvertiserId = "autoTrackAdvertiserId"

	// MARK: remote configuration parameter
	case EnableRemoteConfiguration = "EnableRemoteConfiguration"
	case TrackingConfigurationUrl = "trackingConfigurationUrl"

	// MARK: event based parameter
	case ResendOnStartEventTime = "resendOnStartEventTime"
}

internal extension XMLIndexer {

	internal subscript(key: XmlConfigParameter) -> XMLIndexer {
		do {
			return try self.byKey(key.rawValue)
		} catch let error as Error {
			return .XMLError(error)
		} catch {
			return .XMLError(.Key(key: key.rawValue))
		}
	}
}