import UIKit

internal final class WebtrekkQueue {

	internal typealias TrackingQueueItem = (config: TrackerConfiguration, parameter: TrackingParameter)

	private let _queue = dispatch_queue_create("de.webtrekk.queue", nil)
	private let _pluginsSaveGuard = dispatch_queue_create("de.webtrekk.pluginsSaveGuard", nil)

	private var _plugins = [Plugin] ()
	private let httpClient = HttpClient()

	internal let networkConnectionTimeout = 60 // equals to one minute
	internal let backgroundSessionName = "Webtrekk.BackgroundSession"
	internal let maximumFailedSends = 5
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


	internal init(backupFileUrl: NSURL = NSURL(), initialSendDelay: Int = 5, sendDelay: Int = 180, maximumUrlCount: Int = 1000) {
		self.backupFileUrl = backupFileUrl
		self.initialSendDelay = min(initialSendDelay, sendDelay)
		self.maximumUrlCount = maximumUrlCount
		self.sendDelay = sendDelay
		setUp()
	}


	internal func clear() {
		with(_queue) {
			guard self.queue.itemCount > 0 else {
				return
			}
			log("Dropping \(self.queue.itemCount) items")
			self.queue = Queue<TrackingQueueItem>()
		}
	}

	internal func add(trackingParameter: TrackingParameter, config: TrackerConfiguration) {
		with(_queue) {
			if self.queue.itemCount >= self.maximumUrlCount {
				// max count for store is reached, remove oldest
				self.queue.dequeue()
			}
			self.queue.enqueue(TrackingQueueItem(config: config, parameter: trackingParameter))
		}
		self.sendNextRequestLater()
	}


	private func loadBackups() {
		// TODO: load backups from file
	}


	private func saveBackup() {
		// TODO: save queue to backup file
	}


	private func setUp() {
		loadBackups()

		if queue.itemCount > 0 {
			// TODO: has backups which needs to be send now
		}
		setUpObserver()
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
			// TODO: old lib testet here to be on main thread
			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard self.queue.itemCount > 0 else { // if no item is present, there is nothing to be send
				return
			}
			// TODO: check if there is not already an open connection


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
			delay(delayInSeconds) {
				self.sendNextRequest()
			}

		}
	}

	private func sendNextRequest() {
		with(_queue) {

			// TODO: old lib testet here to be on main thread

			self.sendNextRequestQueued = false

			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard self.queue.itemCount > 0 else { // if no item is present, there is nothing to be send
				log("Nothing to do.")
				return
			}
			// TODO: check if there is not already an open connection

			guard let trackingQueueItem = self.queue.peek() else {
				log("This should never happen, but there is no item on the queue even after testing for that.")
				return
			}

			self.handleBeforePluginCall(trackingQueueItem.parameter)
			// TODO: generate NSURL from config and trackingParameter
			let url = NSURL(string:"https://widgetlabs.eu")!
			self.httpClient.get(url) { (theData, error) -> Void in
				// TODO: handle error
				defer {
					self.sendNextRequestLater()
				}
				guard let error = error else {
					self.queue.dequeue()
					return
				}
				if case .NetworkError(let recoverable) = error as! Error where !recoverable {
					self.queue.dequeue()
				}
			}
		}
	}



}

internal func delay(seconds: Int, closure: ()->()) {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), closure)
}