import UIKit

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
			self.queue.enqueue(TrackingQueueItem(config: config, parameter: trackingParameter))
			if let pageTrackingParameter = trackingParameter as? PageTrackingParameter {
				self.log("Adding \(NSURL(string:pageTrackingParameter.urlWithAllParameter(config))!) to the request queue")
			} else if let actionTrackingParameter = trackingParameter as? ActionTrackingParameter {
				self.log("Adding \(NSURL(string:actionTrackingParameter.urlWithAllParameter(config))!) to the request queue")
			} else {
				self.log("Only PageTrackingParameter and ActionTrackingParameter expected at this Point")
			}
		}
		self.sendNextRequestLater()
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

	private func setUpObserver() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: Selector(stringLiteral: "applicationDidReceiveMemoryWarning"), name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
		notificationCenter.addObserver(self, selector: Selector(stringLiteral: "applicationBecomesInactive"), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
		notificationCenter.addObserver(self, selector: Selector(stringLiteral: "applicationBecomesInactive"), name: UIApplicationWillTerminateNotification, object: UIApplication.sharedApplication())

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

	// TODO: Consider if plugins can change the trackingParameter, as to add more default parameters or change others. use inout if needed

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

//			TODO: check old lib ensured to run on main thread
//			guard NSThread.isMainThread() else {
//				dispatch_async(dispatch_get_main_queue()) {
//					self.sendNextRequestLater()
//				}
//				return
//			}
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

//			TODO: check old lib ensured to run on main thread
//			guard NSThread.isMainThread() else {
//				dispatch_async(dispatch_get_main_queue()) {
//					self.sendNextRequestQueued = true
//					self.sendNextRequest()
//				}
//				return
//			}

			self.sendNextRequestQueued = false

			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard self.queue.itemCount > 0 else { // if no item is present, there is nothing to be send
				self.flush = false
				self.log("Nothing to do.")
				return
			}
			// TODO: check if there is not already an open connection

			guard let trackingQueueItem = self.queue.peek() else {
				self.log("This should never happen, but there is no item on the queue even after testing for that.")
				return
			}

			self.handleBeforePluginCall(trackingQueueItem.parameter)
			// TODO: generate NSURL from config and trackingParameter
			let url: NSURL
			if let pageTrackingParameter = trackingQueueItem.parameter as? PageTrackingParameter {
				url = NSURL(string:pageTrackingParameter.urlWithAllParameter(trackingQueueItem.config))!
			} else if let actionTrackingParameter = trackingQueueItem.parameter as? ActionTrackingParameter {
				url = NSURL(string:actionTrackingParameter.urlWithAllParameter(trackingQueueItem.config))!
			} else {
				fatalError("Only PageTrackingParameter and ActionTrackingParameter expected at this Point")
			}
			guard self.shouldTrack else {
				self.log("user is not tracked")
				self.handleAfterPluginCall(trackingQueueItem.parameter)
				return
			}

			self.log("Request \(url) will be send now.")

			self.httpClient.get(url) { (theData, error) -> Void in
				// TODO: handle error
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