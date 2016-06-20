import Foundation
import UIKit // FIXME


internal final class RequestManager {

	private var events = [TrackingEvent]()
	private var numberOfFailuresForCurrentEvent = 0
	private var pendingTask: NSURLSessionDataTask?
	private var sendNextEventDate: NSDate?
	private var sendNextEventTimer: NSTimer?

	internal var logger: Webtrekk.Logger


	internal init(logger: Webtrekk.Logger) {
		self.logger = logger
	}


	internal func clearPendingEvents() {
		logger.logInfo("Clearing queue of \(events.count) events.")

		events.removeAll()
	}


	internal func enqueueEvent(event: TrackingEvent, maximumDelay: NSTimeInterval) {
		if events.count >= maximumNumberOfEvents {
			logger.logWarning("Too many events in queue. Dropping oldest one.")

			events.removeFirst()
		}

		events.append(event)
		// FIXME save?

		logger.logInfo("Added event to queue: \(event)")

		sendNextEvent(maximumDelay: maximumDelay)
	}



	internal func fetch(url url: NSURL, completion: (NSData?, Error?) -> Void) -> NSURLSessionDataTask {
		let task = NSURLSession.defaultSession().dataTaskWithURL(url) { data, response, error in
			if let error = error {
				let retryable: Bool

				switch error.code {
				case NSURLErrorBadServerResponse,
				     NSURLErrorCallIsActive,
				     NSURLErrorCancelled,
				     NSURLErrorCannotConnectToHost,
				     NSURLErrorCannotFindHost,
				     NSURLErrorDataNotAllowed,
				     NSURLErrorDNSLookupFailed,
				     NSURLErrorInternationalRoamingOff,
				     NSURLErrorNetworkConnectionLost,
				     NSURLErrorNotConnectedToInternet,
				     NSURLErrorTimedOut,
				     NSURLErrorZeroByteResource:

					retryable = true

				default:
					retryable = false
				}

				completion(nil, Error(message: error.localizedDescription, retryable: retryable, underlyingError: error))
				return
			}

			guard let response = response as? NSHTTPURLResponse else {
				completion(nil, Error(message: "No Response", retryable: false))
				return
			}
			guard !(500 ... 599).contains(response.statusCode) else {
				completion(nil, Error(message: "HTTP \(response.statusCode)", retryable: true))
				return
			}
			guard (200 ... 299).contains(response.statusCode), let data = data else {
				completion(nil, Error(message: "HTTP \(response.statusCode)", retryable: false))
				return
			}

			completion(data, nil)
		}
		task.resume()
		
		return task
	}


	internal var eventCount: Int {
		return events.count
	}


	internal var maximumNumberOfEvents: Int {
		didSet {
			precondition(maximumNumberOfEvents > 0)

			if maximumNumberOfEvents < events.count {
				events = Array(events[0 ..< maximumNumberOfEvents])
				// FIXME save?
			}
		}
	}

	
	private func loadBackups() {
	/*	let restoredQueue = backupManager.restoreFromDisc(backupFileUrl)
		guard !restoredQueue.isEmpty else {
			return
		}
		
		synchronized(queueLock) {
			self.queue = restoredQueue
		}*/
	}


	private func saveBackup() {
		/*
		synchronized(queueLock) {
			self.backupManager.saveToDisc(self.backupFileUrl, queue: self.queue)
		}*/
	}


	internal func sendAllEvents() {
		sendNextEvent()
	}


	private func sendNextEvent() {
		sendNextEventTimer?.invalidate()
		sendNextEventTimer = nil

		guard pendingTask == nil && !events.isEmpty else {
			return
		}

		let event = events[0]

		guard let url = UrlCreator.createUrlFromEvent(event) else {
			logger.logError("url is not valid")

			events.removeFirst()
			return
		}

		logger.logInfo("Sending request: \(url)")

		pendingTask = fetch(url: url) { data, error in
			self.pendingTask = nil

			if let error = error {
				guard let requestError = error as? Error where requestError.retryable else {
					self.logger.logError("Request \(url) failed and will not be retried: \(error)")

					self.numberOfFailuresForCurrentEvent = 0
					self.events.removeFirst()
					// TODO save backup?
					return
				}
				guard numberOfRetries < 10 else { // TODO use config
					self.logger.logError("Request \(url) failed and will no longer be retried: \(error)")

					self.numberOfFailuresForCurrentEvent = 0
					self.events.removeFirst()
					// TODO save backup?
					return
				}

				self.numberOfFailuresForCurrentEvent += 1
				self.sendNextEvent(maximumDelay: self.numberOfFailuresForCurrentEvent * 5)
				return
			}

			self.numberOfFailuresForCurrentEvent = 0
			self.events.removeFirst()

			self.sendNextEvent()
			// TODO save backup?
		}
	}


	private func sendNextEvent(maximumDelay maximumDelay: NSTimeInterval) {
		guard !events.isEmpty else {
			return
		}
		guard maximumDelay > 0 else {
			sendAllEvents()
			return
		}

		if let sendNextEventTimer = sendNextEventTimer {
			let fireDate = NSDate(timeIntervalSinceNow: maximumDelay)
			if fireDate.compare(sendNextEventTimer.fireDate) == NSComparisonResult.OrderedAscending {
				sendNextEventTimer.fireDate = fireDate
			}
		}
		else {
			sendNextEventTimer = NSTimer.scheduledTimerWithTimeInterval(maximumDelay) {
				self.sendNextEventTimer = nil
				self.sendAllEvents()
			}
		}
	}


	internal func startSending() {
		sendNextEvent()
	}



	internal struct Error: ErrorType {

		internal var message: String
		internal var retryable: Bool
		internal var underlyingError: ErrorType?


		internal init(message: String, retryable: Bool, underlyingError: ErrorType? = nil) {
			self.message = message
			self.retryable = retryable
			self.underlyingError = underlyingError
		}
	}
}
