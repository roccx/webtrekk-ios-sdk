import Foundation


internal final class RequestManager {

	internal typealias Delegate = _BackupDelegate

	private var events = [NSURLComponents]()
	private var numberOfFailuresForCurrentEvent = 0
	private var pendingTask: NSURLSessionDataTask?
	private var sendNextEventDate: NSDate?
	private var sendNextEventTimer: NSTimer?
	private var isShutingDown: Bool = false

	internal var logger: Webtrekk.Logger
	internal weak var delegate: Delegate?

	internal init(logger: Webtrekk.Logger, backupDelegate: Delegate?, maximumNumberOfEvents: Int) {
		self.logger = logger
		self.maximumNumberOfEvents = maximumNumberOfEvents
		self.delegate = backupDelegate
		loadBackups()
	}


	internal func clearPendingEvents() {
		logger.logInfo("Clearing queue of \(events.count) events.")

		events.removeAll()
	}


	internal func enqueueEvent(event: NSURLComponents, maximumDelay: NSTimeInterval) {
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
				events = Array(events[(events.count - maximumNumberOfEvents - 1) ..< events.count])
				// FIXME save?
			}
		}
	}

	
	private func loadBackups() {
		if let events = delegate?.loadEvents() {
			self.events = events
		}
	}


	private func saveBackup() {
		delegate?.saveEvents(self.events)
	}


	internal func sendAllEvents() { // TODO: talk about sendDelay
		sendNextEvent()
	}


	private func sendNextEvent() {
		sendNextEventTimer?.invalidate()
		sendNextEventTimer = nil


		if isShutingDown, let delegate = delegate {
			delegate.saveEvents(events)
		}

		guard pendingTask == nil && !events.isEmpty else {
			return
		}

		let event = events[0]

		guard let url = event.URL else {
			logger.logError("url is not valid")

			events.removeFirst()
			return
		}

		logger.logInfo("Sending request: \(url)")

		pendingTask = fetch(url: url) { data, error in
			self.pendingTask = nil

			if let error = error {
				guard error.retryable else {
					self.logger.logError("Request \(url) failed and will not be retried: \(error)")

					self.numberOfFailuresForCurrentEvent = 0
					self.events.removeFirst()
					// TODO save backup?
					return
				}
				guard self.numberOfFailuresForCurrentEvent < 10 else { // TODO use config
					self.logger.logError("Request \(url) failed and will no longer be retried: \(error)")

					self.numberOfFailuresForCurrentEvent = 0
					self.events.removeFirst()
					// TODO save backup?
					return
				}

				self.numberOfFailuresForCurrentEvent += 1
				self.sendNextEvent(maximumDelay: Double(self.numberOfFailuresForCurrentEvent * 5))
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


	internal func shutDown() {
		// FIXME: Do it right?
		isShutingDown = true
		sendAllEvents()
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

internal protocol _BackupDelegate: class {

	func loadEvents() -> [NSURLComponents]
	func saveEvents(events: [NSURLComponents])
}
