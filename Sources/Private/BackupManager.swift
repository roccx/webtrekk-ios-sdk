import CoreGraphics
import Foundation


internal final class BackupManager {

	private let fileManager: FileManager

	internal var logger: Webtrekk.Logger


	internal init(fileManager: FileManager, logger: Webtrekk.Logger) {
		self.fileManager = fileManager
		self.logger = logger
	}


	internal func saveEvents(events: [NSURLComponents], to file: NSURL) {
		var jsonEvents = [[String: AnyObject]]()
		for event in events {
			guard let url = event.string as? AnyObject else {
				continue
			}
			jsonEvents.append(["url": url])
		}


		do {
			let data = try NSJSONSerialization.dataWithJSONObject(jsonEvents, options: [])
			fileManager.saveData(toFileUrl: file, data: data)
		}
		catch let error {
			logger.logError("Cannot save pending events to disk: \(error)")
		}

		guard !jsonEvents.isEmpty else{
			logger.logInfo("All events could be sent.")
			return
		}
		logger.logInfo("Stored \(jsonEvents.count) to disc.")
	}


	internal func loadEvents(from file: NSURL) -> [NSURLComponents] {
		guard let data = fileManager.restoreData(fromFileUrl: file) else {
			return []
		}
		guard let jsonEvents: [[String: AnyObject]] = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String: AnyObject]] else {
			logger.logInfo("Data was not a valid json to be restored.")

			return []
		}

		var events = [NSURLComponents]()
		events.reserveCapacity(jsonEvents.count)

		for jsonEvent in jsonEvents {
			guard let urlString = jsonEvent["url"] as? String, url = NSURLComponents(string: urlString) else {
				logger.logError("Cannot load pending event from disk: \(jsonEvent)")
				continue
			}

			events.append(url)
		}

		return events
	}
}

internal protocol Backupable {
	func toJson() -> [String: AnyObject]
	static func fromJson(json: [String: AnyObject]) -> Self?
}

extension TrackerConfiguration: Backupable {
	internal func toJson() -> [String : AnyObject] {
		// FIXME: Do it again
		var items = [String: AnyObject]()
		items["appVersion"] = appVersion
		items["maxRequests"] = maxRequests
		items["samplingRate"] = samplingRate
		items["sendDelay"] = sendDelay
		items["version"] = version
		items["optedOut"] = optedOut
		items["serverUrl"] = serverUrl
		items["trackingId"] = trackingId
		items["autoTrack"] = autoTrack
		items["autoTrackAdvertiserId"] = autoTrackAdvertiserId
		items["autoTrackApiLevel"] = autoTrackApiLevel
		items["autoTrackAppUpdate"] = autoTrackAppUpdate
		items["autoTrackAppVersionName"] = autoTrackAppVersionName
		items["autoTrackAppVersionCode"] = autoTrackAppVersionCode
		items["autoTrackConnectionType"] = autoTrackConnectionType
		items["autoTrackRequestUrlStoreSize"] = autoTrackRequestUrlStoreSize
		items["autoTrackScreenOrientation"] = autoTrackScreenOrientation
		items["enableRemoteConfiguration"] = enableRemoteConfiguration
		items["remoteConfigurationUrl"] = remoteConfigurationUrl
		items["configFilePath"] = configFilePath

//		if !autoTrackScreens.isEmpty {
//			items["autoTrackScreens"] = autoTrackScreens.map({["index":$0.0, "value": $0.1.toJson()]})
//		}
		return items
	}

	static func fromJson(json: [String: AnyObject]) -> TrackerConfiguration? {
		var config: TrackerConfiguration
		guard let trackingId = json["trackingId"] as? String, let serverUrl = json["serverUrl"] as? String else {
			return nil
		}
		if let configFilePath = json["configFilePath"] as? String {
			config = TrackerConfiguration(configFilePath: configFilePath, serverUrl: serverUrl, trackingId: trackingId)
		}
		else {
			config = TrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)
		}

		if let appVersion = json["appVersion"] as? String {
			config.appVersion = appVersion
		}
		if let maxRequests = json["maxRequests"] as? Int {
			config.maxRequests = maxRequests
		}
		if let samplingRate = json["samplingRate"] as? Int {
			config.samplingRate = samplingRate
		}
		if let sendDelay = json["sendDelay"] as? Int {
			config.sendDelay = NSTimeInterval(sendDelay)
		}
		if let version = json["version"] as? Int {
			config.version = version
		}
		if let optedOut = json["optedOut"] as? Bool {
			config.optedOut = optedOut
		}

		if let autoTrack = json["autoTrack"] as? Bool {
			config.autoTrack = autoTrack
		}
		if let autoTrackAdvertiserId = json["autoTrackAdvertiserId"] as? Bool {
			config.autoTrackAdvertiserId = autoTrackAdvertiserId
		}
		if let autoTrackApiLevel = json["autoTrackApiLevel"] as? Bool {
			config.autoTrackApiLevel = autoTrackApiLevel
		}
		if let autoTrackAppUpdate = json["autoTrackAppUpdate"] as? Bool {
			config.autoTrackAppUpdate = autoTrackAppUpdate
		}
		if let autoTrackAppVersionName = json["autoTrackAppVersionName"] as? Bool {
			config.autoTrackAppVersionName = autoTrackAppVersionName
		}
		if let autoTrackAppVersionCode = json["autoTrackAppVersionCode"] as? Bool {
			config.autoTrackAppVersionCode = autoTrackAppVersionCode
		}
		if let autoTrackConnectionType = json["autoTrackConnectionType"] as? Bool {
			config.autoTrackConnectionType = autoTrackConnectionType
		}
		if let autoTrackRequestUrlStoreSize = json["autoTrackRequestUrlStoreSize"] as? Bool {
			config.autoTrackRequestUrlStoreSize = autoTrackRequestUrlStoreSize
		}
		if let autoTrackScreenOrientation = json["autoTrackScreenOrientation"] as? Bool {
			config.autoTrackScreenOrientation = autoTrackScreenOrientation
		}
		if let enableRemoteConfiguration = json["enableRemoteConfiguration"] as? Bool {
			config.enableRemoteConfiguration = enableRemoteConfiguration
		}
		if let remoteConfigurationUrl = json["remoteConfigurationUrl"] as? String {
			config.remoteConfigurationUrl = remoteConfigurationUrl
		}
		if let autoScreenDic = json["autoTrackScreens"] as? [[String: AnyObject]] {
			for item in autoScreenDic {
				guard let index = item["index"] as? String, let value = item["value"] as? [String: AnyObject] else {
					continue
				}
//				config.autoTrackScreens[index] =  AutoTrackedScreen.fromJson(value)
			}
		}
		return config
	}
}


extension BackupManager: RequestManager.Delegate {

	internal func loadEvents() -> [NSURLComponents] {
		return loadEvents(from: fileManager.eventFileUrl)
	}


	internal func saveEvents(events: [NSURLComponents]) {
		saveEvents(events, to: fileManager.eventFileUrl)
	}
}
