import Foundation


internal final class RequestManager {

	internal typealias Delegate = _BackupDelegate

	private var requests = [NSURL]()
	private var numberOfFailuresForCurrentRequest = 0
	private var pendingTask: NSURLSessionDataTask?
	private var sendNextRequestDate: NSDate?
	private var sendNextRequestTimer: NSTimer?
	private var isShutingDown: Bool = false

	internal weak var delegate: Delegate?
	internal var serverUrl: NSURL
	internal var webtrekkId: String


	internal init(backupDelegate: Delegate?, maximumNumberOfRequests: Int, serverUrl: NSURL, webtrekkId: String) {
		self.maximumNumberOfRequests = maximumNumberOfRequests
		self.delegate = backupDelegate
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId

		loadBackups()
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
		logInfo("Clearing queue of \(requests.count) events.")

		requests.removeAll()
	}


	internal func enqueueRequest(request: TrackerRequest, maximumDelay: NSTimeInterval) {
		if requests.count >= maximumNumberOfRequests {
			logWarning("Too many events in queue. Dropping oldest one.")

			requests.removeFirst()
		}

		guard let url = UrlCreator.createUrlFromEvent(request, serverUrl: serverUrl, webtrekkId: webtrekkId) else {
			return
		}

		requests.append(url)
		// FIXME save?

		logInfo("Added event to queue: \(request)")

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


	internal var requestCount: Int {
		return requests.count
	}


	internal var maximumNumberOfRequests: Int {
		didSet {
			precondition(maximumNumberOfRequests > 0)

			if maximumNumberOfRequests < requests.count {
				requests = Array(requests[(requests.count - maximumNumberOfRequests - 1) ..< requests.count])
				// FIXME save?
			}
		}
	}

	
	private func loadBackups() {
		if let requests = delegate?.loadRequests() {
			self.requests = requests
		}
	}


	private func saveBackup() {
		delegate?.saveRequests(self.requests)
	}


	internal func sendAllRequests() { // TODO: talk about sendDelay
		sendNextRequest()
	}


	private func sendNextRequest() {
		sendNextRequestTimer?.invalidate()
		sendNextRequestTimer = nil


		if isShutingDown, let delegate = delegate {
			delegate.saveRequests(requests)
		}

		guard pendingTask == nil else {
			return
		}

		guard !requests.isEmpty else {
			isShutingDown = false
			return
		}
		

		let url = requests[0]

		logInfo("Sending request: \(url)")

		pendingTask = fetch(url: url) { data, error in
			self.pendingTask = nil

			if let error = error {
				guard error.retryable else {
					logError("Request \(url) failed and will not be retried: \(error)")

					self.numberOfFailuresForCurrentRequest = 0

					if self.requests.first == url {
						self.requests.removeFirst()
					}

					// TODO save backup?
					return
				}
				guard self.numberOfFailuresForCurrentRequest < 10 else { // TODO use config
					logError("Request \(url) failed and will no longer be retried: \(error)")

					self.numberOfFailuresForCurrentRequest = 0

					if self.requests.first == url {
						self.requests.removeFirst()
					}

					// TODO save backup?
					return
				}

				self.numberOfFailuresForCurrentRequest += 1
				self.sendNextRequest(maximumDelay: Double(self.numberOfFailuresForCurrentRequest * 5))
				return
			}

			self.numberOfFailuresForCurrentRequest = 0

			if self.requests.first == url {
				self.requests.removeFirst()
			}

			self.sendNextRequest()
			// TODO save backup?
		}
	}


	private func sendNextRequest(maximumDelay maximumDelay: NSTimeInterval) {
		guard !requests.isEmpty else {
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


	internal func shutDown() {
		// FIXME: Do it right?
		isShutingDown = true
		sendAllRequests()
	}


	internal func startSending() {
		sendNextRequest()
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

	func loadRequests() -> [NSURL]
	func saveRequests(requests: [NSURL])
}
