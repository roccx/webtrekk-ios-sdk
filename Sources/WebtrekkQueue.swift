import UIKit

internal final class WebtrekkQueue {

	internal typealias TrackingQueueItem = (config: TrackerConfiguration, parameter: TrackingParameter)

	internal let networkConnectionTimeout = 60 // equals to one minute
	internal let backgroundSessionName = "Webtrekk.BackgroundSession"
	internal var queue = Queue<TrackingQueueItem>()

	internal private(set) var backupFileUrl: NSURL
	internal private(set) var initialSendDelay: Int
	internal private(set) var maximumUrlCount: Int
	internal private(set) var sendDelay: Int


	deinit {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
		notificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
		notificationCenter.removeObserver(self, name: UIApplicationWillTerminateNotification, object: nil)
	}


	internal init(backupFileUrl: NSURL = NSURL(), initialSendDelay: Int = 5, sendDelay: Int = 180, maximumUrlCount: Int = 1000) {
		self.backupFileUrl = backupFileUrl
		self.initialSendDelay = initialSendDelay
		self.maximumUrlCount = maximumUrlCount
		self.sendDelay = sendDelay
		setUp()
	}


	internal func clear() {
		guard queue.itemCount > 0 else {
			return
		}
		log("Dropping \(queue.itemCount) items")
		queue = Queue<TrackingQueueItem>()
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