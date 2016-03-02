import UIKit

internal final class WebtrekkQueue {

	internal typealias TrackingQueueItem = (config: TrackerConfiguration, parameter: TrackingParameter)

	private let _queue = dispatch_queue_create("de.webtrekk.queue", nil)
	private var _plugins = [Plugin] ()

	internal let networkConnectionTimeout = 60 // equals to one minute
	internal let backgroundSessionName = "Webtrekk.BackgroundSession"
	internal private(set) var queue = Queue<TrackingQueueItem>()

	internal private(set) var backupFileUrl: NSURL
	internal private(set) var initialSendDelay: Int
	internal private(set) var maximumUrlCount: Int
	internal private(set) var numberOfSuccessfulSends = 0
	internal private(set) var sendDelay: Int
	internal private(set) var shutdownRequested = false


	internal var plugins: [Plugin] {
		get {
			var result: [Plugin]?
			with(_queue) {
				result = self._plugins
			}
			return result!
		}
		set {
			with(_queue) {
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
		for plugin in plugins {
			plugin.afterTrackingSend(trackingParameter)
		}
	}

	// TODO: Consider if plugins can change the trackingParameter, as to add more default parameters or change others. use inout if needed

	internal func handleBeforePluginCall(trackingParameter: TrackingParameter) {
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

			
		}
	}


}