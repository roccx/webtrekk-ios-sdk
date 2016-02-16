import Foundation
import SWXMLHash

internal class XmlConfigParser: ConfigParser {

	var trackerConfiguration: TrackerConfiguration {
		get {
			guard let serverUrl = xml[.ROOT][.TRACKING_DOMAIN].element?.text, let trackingId = xml[.ROOT][.TRACK_ID].element?.text else {
				fatalError("tracking domain and id needs to be set")
			}
			var config = DefaultTrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)

			if let maxRequests = Int((xml[.ROOT][.MAX_REQUESTS].element?.text)!) {
				config.maxRequests = maxRequests
			}

			if let sampling = Int((xml[.ROOT][.SAMPLING].element?.text)!) {
				config.samplingRate = sampling
			}

			if let sendDelay = Int((xml[.ROOT][.SEND_DELAY].element?.text)!) {
				config.sendDelay = sendDelay
			}

			if let version = Int((xml[.ROOT][.VERSION].element?.text)!) {
				config.version = version
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
	case AUTO_TRACK_APP_VERSION_CODE = "autoTrackApp"
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