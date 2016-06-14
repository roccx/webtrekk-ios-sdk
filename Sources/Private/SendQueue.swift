import UIKit

internal final class SendQueue: Logable {

	var loger: Loger

	internal typealias TrackingQueueItem = Event

	private let _queue = dispatch_queue_create("de.webtrekk.queue", nil)

	private lazy var session: NSURLSession = NSURLSession.defaultSession()
	private lazy var backupManager: BackupManager = BackupManager(self.loger)

	internal let networkConnectionTimeout = 60 // equals to one minute
	internal let backgroundSessionName = "Webtrekk.BackgroundSession"
	internal let maximumFailedSends = 5
	internal var flush = false
	internal var shouldTrack = true
	internal var advertisingIdentifier: (() -> String?)?
	internal private(set) var queue = Array<TrackingQueueItem>()

	internal private(set) var backupFileUrl: NSURL
	internal private(set) var initialSendDelay: Int
	internal private(set) var maximumUrlCount: Int
	internal private(set) var numberOfSuccessfulSends = 0
	internal private(set) var numberOfFailedSends = 0
	internal private(set) var sendDelay: Int
	internal private(set) var shutdownRequested = false
	internal private(set) var sendNextRequestQueued = false


	internal var itemCount: Int {
		get { return queue.count }
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
			guard !self.queue.isEmpty else {
				return
			}
			self.log("Dropping \(self.queue.count) items")
			self.queue = Array<TrackingQueueItem>()
		}
	}

	internal func add(event: Event) {
		with(_queue) {
			if self.queue.count >= self.maximumUrlCount {
				self.log("Max count for store is reached, removing oldest now.")
				self.queue.dequeue()
			}
			self.queue.enqueue(event)
			self.log("Adding \(UrlCreator.createUrlFromEvent(event)) to the request queue")

		}
		self.sendNextRequestLater()
	}

	
	private func loadBackups() {
		let restoredQueue = backupManager.restoreFromDisc(backupFileUrl)
		guard !restoredQueue.isEmpty else {
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
			guard !self.queue.isEmpty else {
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

extension SendQueue {

	@objc private func applicationDidReceiveMemoryWarning() {
		log("Application may be killed soon")
		saveBackup()
	}


	@objc private func applicationBecomesInactive() {
		log("Application no longer in foreground")
		saveBackup()
		with(_queue) {
			guard !self.queue.isEmpty else {
				return
			}
			self.log("Trying to send out \(self.queue.count) remaining requests.")
			self.flush = true
		}
		if flush {
			self.sendNextRequest()
		}
	}
}


extension SendQueue { // Sending

	private func sendNextRequestLater() {
		with(_queue) {

			guard !self.shutdownRequested else { // nothing will be send if queue is shutting down
				return
			}

			guard !self.queue.isEmpty else { // if no item is present, there is nothing to be send
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

			guard !self.queue.isEmpty else { // if no item is present, there is nothing to be send
				self.flush = false
				self.log("Nothing to do.")
				return
			}
			
			guard let trackingQueueItem = self.queue.peek() else {
				self.log("This should never happen, but there is no item on the queue even after testing for that.")
				return
			}

			guard let url = UrlCreator.createUrlFromEvent(trackingQueueItem) else {
				self.log("url is not valid")
				self.queue.dequeue()
				return
			}

			self.log("Request \(url) will be send now.")


			NSURLSession.get(url, session: self.session, loger: self.loger) { (theData, error) -> Void in
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
						self.queue.dequeue()
						return
					}
					self.numberOfFailedSends += 1
					if case .NetworkError(let recoverable) = error as! Error where !recoverable {
						let item = self.queue.dequeue()
						self.log("Request \(item) was not recoverable.")
					}
					if self.numberOfFailedSends > 10 {
						let item = self.queue.dequeue()
						self.log("Request \(item) failed too often and will be removed.")
					}
				}
			}
		}
	}
}