import UIKit
import ReachabilitySwift

internal final class WebtrekkQueue: Logable {

	var loger: Loger

	internal typealias TrackingQueueItem = (config: TrackerConfiguration, parameter: TrackingParameter)

	private let _queue = dispatch_queue_create("de.webtrekk.queue", nil)
	private let _pluginsSaveGuard = dispatch_queue_create("de.webtrekk.pluginsSaveGuard", nil)

	private var _plugins = [Plugin] ()
	private let httpClient = DefaultHttpClient()
	private lazy var backupManager: BackupManager = BackupManager(self.loger)

	internal let networkConnectionTimeout = 60 // equals to one minute
	internal let backgroundSessionName = "Webtrekk.BackgroundSession"
	internal let maximumFailedSends = 5
	internal var flush = false
	internal var shouldTrack = true
	internal var advertisingIdentifier: (() -> String?)?
	internal private(set) var queue = Queue<TrackingQueueItem>()

	internal private(set) var backupFileUrl: NSURL
	internal private(set) var initialSendDelay: Int
	internal private(set) var maximumUrlCount: Int
	internal private(set) var numberOfSuccessfulSends = 0
	internal private(set) var numberOfFailedSends = 0
	internal private(set) var sendDelay: Int
	internal private(set) var shutdownRequested = false
	internal private(set) var sendNextRequestQueued = false

	internal var plugins: [Plugin] {
		get {
			var result: [Plugin]?
			with(_pluginsSaveGuard) {
				result = self._plugins
			}
			return result!
		}
		set {
			with(_pluginsSaveGuard) {
				self._plugins = newValue
			}
		}
	}


	deinit {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
		notificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
		notificationCenter.removeObserver(self, name: UIApplicationWillTerminateNotification, object: nil)
	}


	internal init(backupFileUrl: NSURL = NSURL(), initialSendDelay: Int = 5, sendDelay: Int = 180, maximumUrlCount: Int = 1000, loger: Loger) {
		self.backupFileUrl = backupFileUrl
		self.initialSendDelay = min(initialSendDelay, sendDelay)
		self.maximumUrlCount = maximumUrlCount
		self.sendDelay = sendDelay
		self.loger = loger
		setUp()
	}


	internal func clear() {
		with(_queue) {
			guard self.queue.itemCount > 0 else {
				return
			}
			self.log("Dropping \(self.queue.itemCount) items")
			self.queue = Queue<TrackingQueueItem>()
		}
	}

	internal func add(trackingParameter: TrackingParameter, config: TrackerConfiguration) {
		with(_queue) {
			if self.queue.itemCount >= self.maximumUrlCount {
				self.log("Max count for store is reached, removing oldest now.")
				self.queue.dequeue()
			}
			let preparedConfig = self.prepare(config)
			var enhancedTrackingParameter = trackingParameter
			enhancedTrackingParameter.generalParameter.samplingRate = config.samplingRate
			self.queue.enqueue(TrackingQueueItem(config: preparedConfig, parameter: enhancedTrackingParameter))
			self.log("Adding \(NSURL(string:enhancedTrackingParameter.urlWithAllParameter(preparedConfig))!) to the request queue")

		}
		self.sendNextRequestLater()
	}

	private func prepare(config: TrackerConfiguration) -> TrackerConfiguration{
		// TODO: Rename parameter names to the correct ones
		var urlString = ""
		if config.autoTrack {
			if config.autoTrackAdvertiserId, let advertisingIdentifier = advertisingIdentifier, let id = advertisingIdentifier() {
				urlString += "&\(ParameterName.urlParameter(fromName: .AdvertiserId, andValue: id))"
			}

			if config.autoTrackConnectionType, let reachability = try? Reachability.reachabilityForInternetConnection() {
				urlString += "&\(ParameterName.urlParameter(fromName: .ConnectionType, andValue: reachability.isReachableViaWiFi() ? "0" : "1"))"
			}

			if config.autoTrackRequestUrlStoreSize {
				urlString += "&\(ParameterName.urlParameter(fromName: .RequestUrlStoreSize, andValue: "\(queue.itemCount)"))"
			}

			if config.autoTrackAppVersionName {
				if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
					urlString += "&\(ParameterName.urlParameter(fromName: .AppVersionName, andValue: config.appVersion.isEmpty ? version : config.appVersion))"
				}
			}

			if config.autoTrackAppVersionCode {
				if let version = NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as? String {
					urlString += "&\(ParameterName.urlParameter(fromName: .AppVersionCode, andValue: version))"
				}
			}

			if config.autoTrackScreenOrientation {
				urlString += "&\(ParameterName.urlParameter(fromName: .ScreenOrientation, andValue: UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ? "1" : "0"))"
			}

			if config.autoTrackAppUpdate {
				var appVersion: String
				if !config.appVersion.isEmpty {
					appVersion = config.appVersion
				} else if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
					appVersion = version
				}else {
					appVersion = ""
				}

				let userDefaults = NSUserDefaults.standardUserDefaults()
				if let version = userDefaults.stringForKey(UserStoreKey.VersionNumber) {
					if version != appVersion {
						userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
						urlString += "&\(ParameterName.urlParameter(fromName: .AppUpdate, andValue: "1"))"
					}
				} else {
					userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
				}
			}
			//				public var autoTrackAppUpdate: Bool
		}
		var confCopy = config
		confCopy.onQueueAutoTrackParameters = urlString.isEmpty ? nil : urlString
		return confCopy
	}

	private func loadBackups() {
		let restoredQueue = backupManager.restoreFromDisc(backupFileUrl)
		guard !restoredQueue.isEmpty() else {
			return
		}
		
		with(_queue) {
			self.queue = restoredQueue
		}
	}


	private func saveBackup() {
		with(_queue) {
			self.backupManager.saveToDisc(self.backupFileUrl, queue: self.queue)
		}
	}


	private func setUp() {
		loadBackups()
		setUpObserver()

		with(_queue) {
			guard self.queue.itemCount > 0 else {
				return
			}
			self.flush = true
		}
		if flush {
			self.sendNextRequest()
		}
	}

	internal func flushNow() {
		with(_queue) {
			self.flush = true
		}
		self.sendNextRequest()
	}

	private func setUpObserver() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: #selector(applicationDidReceiveMemoryWarning), name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
		notificationCenter.addObserver(self, selector: #selector(applicationBecomesInactive), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
		notificationCenter.addObserver(self, selector: #selector(applicationBecomesInactive), name: UIApplicationWillTerminateNotification, object: UIApplication.sharedApplication())

		}
}

extension WebtrekkQueue {

	@objc private func applicationDidReceiveMemoryWarning() {
		log("Application may be killed soon")
		saveBackup()
	}


	@objc private func applicationBecomesInactive() {
		log("Application no longer in foreground")
		saveBackup()
		with(_queue) {
			guard self.queue.itemCount > 0 else {
				return
			}
			self.log("Trying to send out \(self.queue.itemCount) remaining requests.")
			self.flush = true
		}
		if flush {
			self.sendNextRequest()
		}
	}
}

extension WebtrekkQueue { // Plugins

	internal func handleAfterPluginCall(trackingParameter: TrackingParameter) {
		guard !plugins.isEmpty else {
			return
		}

		for plugin in plugins {
			plugin.afterTrackingSend(trackingParameter)
		}
	}


	internal func handleBeforePluginCall(trackingParameter: TrackingParameter) {
		guard !plugins.isEmpty else {
			return
		}

		for plugin in plugins {
			plugin.beforeTrackingSend(trackingParameter)
		}
	}

}

extension WebtrekkQueue { // Sending

	private func sendNextRequestLater() {
		with(_queue) {

			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard self.queue.itemCount > 0 else { // if no item is present, there is nothing to be send
				self.log("Nothing to do.")
				return
			}


			guard !self.sendNextRequestQueued else { // check that we are not having any other request already in for delay
				return
			}

			self.sendNextRequestQueued = true
			let delayInSeconds: Int
			if self.numberOfSuccessfulSends == 0 && self.numberOfFailedSends <  self.maximumFailedSends {
				delayInSeconds = self.initialSendDelay
			} else {
				delayInSeconds = self.sendDelay
			}
			self.log("Sending next request in \(delayInSeconds) sec.")
			delay(delayInSeconds) {
				self.sendNextRequest()
			}

		}
	}

	private func sendNextRequest() {
		with(_queue) {

			self.sendNextRequestQueued = false

			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard self.queue.itemCount > 0 else { // if no item is present, there is nothing to be send
				self.flush = false
				self.log("Nothing to do.")
				return
			}
			
			guard let trackingQueueItem = self.queue.peek() else {
				self.log("This should never happen, but there is no item on the queue even after testing for that.")
				return
			}

			self.handleBeforePluginCall(trackingQueueItem.parameter)

			guard let url = NSURL(string:trackingQueueItem.parameter.urlWithAllParameter(trackingQueueItem.config)) else {
				self.log("url is not valid")
				self.queue.dequeue()
				return
			}

			guard self.shouldTrack else {
				self.log("user is not tracked")
				self.handleAfterPluginCall(trackingQueueItem.parameter)
				return
			}

			self.log("Request \(url) will be send now.")

			self.httpClient.get(url) { (theData, error) -> Void in
				defer {
					if self.flush {
						self.saveBackup()
						self.sendNextRequest()
					}
					else {
						self.sendNextRequestLater()
					}
				}
				with(self._queue) {
					guard let error = error else {
						self.numberOfSuccessfulSends = 1
						self.numberOfFailedSends = 0
						if let item = self.queue.dequeue() {
							self.handleAfterPluginCall(item.parameter)
						}
						return
					}
					self.numberOfFailedSends += 1
					if case .NetworkError(let recoverable) = error as! Error where !recoverable {
						if let item = self.queue.dequeue() {
							self.handleAfterPluginCall(item.parameter)
						}
					}
				}
			}
		}
	}
}