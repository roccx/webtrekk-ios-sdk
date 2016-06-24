import Foundation


internal final class RequestManager {

	internal typealias Delegate = _RequestManagerDelegate

	private var numberOfFailuresForCurrentRequest = 0
	private var pendingTask: NSURLSessionDataTask?
	private var sendNextRequestTimer: NSTimer?

	internal private(set) var queue = [NSURL]()
	internal private(set) var started = false

	internal var serverUrl: NSURL
	internal var webtrekkId: String

	internal weak var delegate: Delegate?


	internal init(serverUrl: NSURL, webtrekkId: String, queueLimit: Int) {
		self.queueLimit = queueLimit
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	private func cancelCurrentRequest() {
		guard let pendingTask = pendingTask else {
			return
		}

		pendingTask.cancel()

		self.numberOfFailuresForCurrentRequest = 0
		self.pendingTask = nil
	}


	internal func clearPendingRequests() {
		logInfo("Clearing queue of \(queue.count) requests.")

		queue.removeAll()
	}


	internal func enqueueRequest(request: TrackerRequest, maximumDelay: NSTimeInterval) {
		if queue.count >= queueLimit {
			logWarning("Too many requests in queue. Dropping oldest one.")

			queue.removeFirst()
		}

		guard let url = UrlCreator.createUrlFromEvent(request, serverUrl: serverUrl, webtrekkId: webtrekkId) else {
			return
		}

		queue.append(url)

		logInfo("Queued: \(url)")

		sendNextRequest(maximumDelay: maximumDelay)
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


	internal func prependRequests(requests: [NSURL]) {
		queue.insertContentsOf(requests, at: 0)
		
		removeRequestsExceedingQueueLimit()
	}


	internal var queueLimit: Int {
		didSet {
			precondition(queueLimit > 0)

			removeRequestsExceedingQueueLimit()
		}
	}


	internal var queueSize: Int {
		return queue.count
	}


	private func removeRequestsExceedingQueueLimit() {
		if queueLimit < queue.count {
			queue = Array(queue[(queue.count - queueLimit - 1) ..< queue.count])
		}
	}


	internal func sendAllRequests() {
		sendNextRequest()
	}


	private func sendNextRequest() {
		sendNextRequestTimer?.invalidate()
		sendNextRequestTimer = nil

		guard started else {
			return
		}
		guard pendingTask == nil else {
			return
		}
		guard !queue.isEmpty else {
			return
		}

		let url = queue[0]

		logInfo("Sending: \(url)")

		pendingTask = fetch(url: url) { data, error in
			self.pendingTask = nil

			if let error = error {
				guard error.retryable else {
					logError("Request \(url) failed and will not be retried: \(error)")

					self.numberOfFailuresForCurrentRequest = 0
					self.queue.removeFirstEqual(url)

					self.delegate?.requestManager(self, didFailToSendRequest: url, error: error)
					return
				}
				guard self.numberOfFailuresForCurrentRequest < 10 else {
					logError("Request \(url) failed and will no longer be retried: \(error)")

					self.numberOfFailuresForCurrentRequest = 0
					self.queue.removeFirstEqual(url)

					self.delegate?.requestManager(self, didFailToSendRequest: url, error: error)
					return
				}

				self.numberOfFailuresForCurrentRequest += 1
				self.sendNextRequest(maximumDelay: Double(self.numberOfFailuresForCurrentRequest * 5))
				return
			}

			self.numberOfFailuresForCurrentRequest = 0
			self.queue.removeFirstEqual(url)

			logInfo("Sent: \(url)")

			self.delegate?.requestManager(self, didSendRequest: url)

			self.sendNextRequest()
		}
	}


	private func sendNextRequest(maximumDelay maximumDelay: NSTimeInterval) {
		guard !queue.isEmpty else {
			return
		}
		guard maximumDelay > 0 else {
			sendAllRequests()
			return
		}

		if let sendNextRequestTimer = sendNextRequestTimer {
			let fireDate = NSDate(timeIntervalSinceNow: maximumDelay)
			if fireDate.compare(sendNextRequestTimer.fireDate) == NSComparisonResult.OrderedAscending {
				sendNextRequestTimer.fireDate = fireDate
			}
		}
		else {
			sendNextRequestTimer = NSTimer.scheduledTimerWithTimeInterval(maximumDelay) {
				self.sendNextRequestTimer = nil
				self.sendAllRequests()
			}
		}
	}


	internal func start() {
		guard !started else {
			logWarning("Cannot start RequestManager which was already started.")
			return
		}

		started = true

		sendNextRequest()
	}


	internal func stop() {
		guard started else {
			logWarning("Cannot stop RequestManager which wasn't started.")
			return
		}

		started = false

		sendNextRequestTimer?.invalidate()
		sendNextRequestTimer = nil
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


internal protocol _RequestManagerDelegate: class {

	func requestManager (requestManager: RequestManager, didSendRequest request: NSURL)
	func requestManager (requestManager: RequestManager, didFailToSendRequest request: NSURL, error: RequestManager.Error)
}
