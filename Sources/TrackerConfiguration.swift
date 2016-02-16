import Foundation

public protocol TrackerConfiguration {
	var appVersionParameter: String { get set }
	var maxRequests:         Int    { get set }
	var samplingRate:        Int    { get set }
	var sendDelay:           Int    { get set }
	var useAdIdentifier:     Bool   { get set }
	var version:             Int    { get set }
	var serverUrl:           String { get }
	var trackingId:          String { get }

	// MARK: Parameters for automatic tracking
	var autoTrack: Bool { get set }
	var autoTrackAppUpdate: Bool { get set }
	var autoTrackAppVersionName: Bool { get set }
	var autoTrackAppVersionCode: Bool { get set }
	var autoTrackApiLevel: Bool { get set }
	var autoTrackScreenOrientation: Bool { get set }
	var autoTrackConnectionType: Bool { get set }
	var autoTrackRequestUrlStoreSize: Bool { get set }
	var autoTrackAdvertiserId: Bool { get set }

	// MARK: remote configuration parameter
	var enableRemoteConfiguration: Bool { get set }
	var remoteConfigurationUrl: String { get set }

}

internal extension TrackerConfiguration {

	internal var baseUrl: NSURL {
		get { return NSURL(string: serverUrl)!.URLByAppendingPathComponent(trackingId).URLByAppendingPathComponent("wt")}
	}
}

internal struct DefaultTrackerConfiguration: TrackerConfiguration {
	internal var appVersionParameter: String
	internal var maxRequests:         Int
	internal var samplingRate:        Int
	internal var sendDelay:           Int
	internal var useAdIdentifier:     Bool
	internal var version:             Int

	internal private(set) var serverUrl:  String
	internal private(set) var trackingId: String


	internal var autoTrack: Bool
	internal var autoTrackAdvertiserId: Bool
	internal var autoTrackApiLevel: Bool
	internal var autoTrackAppUpdate: Bool
	internal var autoTrackAppVersionName: Bool
	internal var autoTrackAppVersionCode: Bool
	internal var autoTrackConnectionType: Bool
	internal var autoTrackRequestUrlStoreSize: Bool
	internal var autoTrackScreenOrientation: Bool

	internal var enableRemoteConfiguration: Bool
	internal var remoteConfigurationUrl: String

	internal init(autoTrack: Bool = true, autoTrackAdvertiserId: Bool = true, autoTrackApiLevel: Bool = true, autoTrackAppUpdate: Bool = true, autoTrackAppVersionName: Bool = true, autoTrackAppVersionCode: Bool = true, autoTrackConnectionType: Bool = true, autoTrackRequestUrlStoreSize: Bool = true, autoTrackScreenOrientation: Bool = true, appVersionParameter: String = "",enableRemoteConfiguration: Bool = false, maxRequests: Int = 1000, remoteConfigurationUrl: String = "", samplingRate: Int = 0, sendDelay: Int = 5 * 60, serverUrl: String, trackingId: String, useAdIdentifier: Bool = false, version: Int = 0) {
		guard !serverUrl.isEmpty || !trackingId.isEmpty else {
			fatalError("Need serverUrl and trackingId for minimal Configuration")
		}

		guard let _ = NSURL(string: serverUrl) else {
			fatalError("serverUrl needs to be a valid url")
		}

		self.appVersionParameter = appVersionParameter
		self.maxRequests = maxRequests
		self.samplingRate = samplingRate
		self.sendDelay = sendDelay
		self.serverUrl = serverUrl
		self.trackingId = trackingId
		self.useAdIdentifier = useAdIdentifier
		self.version = version
		self.autoTrack = autoTrack
		self.autoTrackApiLevel = autoTrackApiLevel
		self.autoTrackAppUpdate = autoTrackAppUpdate
		self.autoTrackAdvertiserId = autoTrackAdvertiserId
		self.autoTrackAppVersionCode = autoTrackAppVersionCode
		self.autoTrackAppVersionName = autoTrackAppVersionName
		self.autoTrackConnectionType = autoTrackConnectionType
		self.autoTrackScreenOrientation = autoTrackScreenOrientation
		self.autoTrackRequestUrlStoreSize = autoTrackRequestUrlStoreSize
		self.enableRemoteConfiguration = enableRemoteConfiguration
		self.remoteConfigurationUrl = remoteConfigurationUrl
	}

}
