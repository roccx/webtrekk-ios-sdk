import Foundation
import SWXMLHash

internal class XmlConfigParser: ConfigParser {

	var trackerConfiguration: TrackerConfiguration {
		get {
			guard xml[.ROOT].boolValue else {
				fatalError("xml root node not found")
			}
			guard xml[.ROOT][.TRACKING_DOMAIN].boolValue && xml[.ROOT][.TRACK_ID].boolValue, let serverUrl = xml[.ROOT][.TRACKING_DOMAIN].element?.text, let trackingId = xml[.ROOT][.TRACK_ID].element?.text else {
				fatalError("tracking domain and id needs to be set")
			}
			var config = DefaultTrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)

			if xml[.ROOT][.MAX_REQUESTS].boolValue, let maxRequests = Int((xml[.ROOT][.MAX_REQUESTS].element?.text)!) {
				config.maxRequests = maxRequests
			}
			if xml[.ROOT][.SAMPLING].boolValue, let sampling = Int((xml[.ROOT][.SAMPLING].element?.text)!) {
				config.samplingRate = sampling
			}
			if xml[.ROOT][.SEND_DELAY].boolValue, let sendDelay = Int((xml[.ROOT][.SEND_DELAY].element?.text)!) {
				config.sendDelay = sendDelay
			}
			if xml[.ROOT][.VERSION].boolValue, let version = Int((xml[.ROOT][.VERSION].element?.text)!) {
				config.version = version
			}

			if xml[.ROOT][.ENABLE_REMOTE_CONFIGURATION].boolValue {
				config.enableRemoteConfiguration = Bool((xml[.ROOT][.ENABLE_REMOTE_CONFIGURATION].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.TRACKING_CONFIGURATION_URL].boolValue, let remoteConfigurationUrl = xml[.ROOT][.TRACKING_CONFIGURATION_URL].element?.text {
				config.remoteConfigurationUrl = remoteConfigurationUrl
			}

			if xml[.ROOT][.AUTO_TRACKED].boolValue {
				config.autoTrack = Bool((xml[.ROOT][.AUTO_TRACKED].element?.text)!.lowercaseString == "true")
			}

			guard config.autoTrack else {
				return config
			}

			if xml[.ROOT][.AUTO_TRACK_APP_UPDATE].boolValue {
				config.autoTrackAppUpdate = Bool((xml[.ROOT][.AUTO_TRACK_APP_UPDATE].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_APP_VERSION_NAME].boolValue {
				config.autoTrackAppVersionName = Bool((xml[.ROOT][.AUTO_TRACK_APP_VERSION_NAME].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_APP_VERSION_CODE].boolValue {
				config.autoTrackAppVersionCode = Bool((xml[.ROOT][.AUTO_TRACK_APP_VERSION_CODE].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_API_LEVEL].boolValue {
				config.autoTrackApiLevel = Bool((xml[.ROOT][.AUTO_TRACK_API_LEVEL].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_SCREEN_ORIENTATION].boolValue {
				config.autoTrackScreenOrientation = Bool((xml[.ROOT][.AUTO_TRACK_SCREEN_ORIENTATION].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_CONNECTION_TYPE].boolValue {
				config.autoTrackConnectionType = Bool((xml[.ROOT][.AUTO_TRACK_CONNECTION_TYPE].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_REQUEST_URL_STORE_SIZE].boolValue {
				config.autoTrackRequestUrlStoreSize = Bool((xml[.ROOT][.AUTO_TRACK_REQUEST_URL_STORE_SIZE].element?.text)!.lowercaseString == "true")
			}
			if xml[.ROOT][.AUTO_TRACK_ADVERTISER_ID].boolValue {
				config.autoTrackAdvertiserId = Bool((xml[.ROOT][.AUTO_TRACK_ADVERTISER_ID].element?.text)!.lowercaseString == "true")
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
	case ROOT = "webtrekkConfiguration"

	// MARK: required parameters
	case TRACKING_DOMAIN = "trackDomain"
	case TRACK_ID = "trackId"

	// MARK: default parameters
	case MAX_REQUESTS = "maxRequests"
	case SAMPLING = "sampling"
	case SEND_DELAY = "sendDelay"
	case VERSION = "version"

	// MARK: auto parameters
	case AUTO_TRACKED = "autoTracked"
	case AUTO_TRACK_APP_UPDATE = "autoTrackAppUpdate"
	case AUTO_TRACK_APP_VERSION_NAME = "autoTrackAppVersionName"
	case AUTO_TRACK_APP_VERSION_CODE = "autoTrackAppVersionCode"
	case AUTO_TRACK_API_LEVEL = "autoTrackApiLevel"
	case AUTO_TRACK_SCREEN_ORIENTATION = "autoTrackScreenOrientation"
	case AUTO_TRACK_CONNECTION_TYPE = "autoTrackConnectionType"
	case AUTO_TRACK_REQUEST_URL_STORE_SIZE = "autoTrackRequestUrlStoreSize"

	// MARK: advertiser id
	case AUTO_TRACK_ADVERTISER_ID = "autoTrackAdvertiserId"

	// MARK: remote configuration parameter
	case ENABLE_REMOTE_CONFIGURATION = "enableRemoteConfiguration"
	case TRACKING_CONFIGURATION_URL = "trackingConfigurationUrl"

	// MARK: event based parameter
	case RESEND_ON_START_EVENT_TIME = "resendOnStartEventTime"
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