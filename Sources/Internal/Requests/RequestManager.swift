import Foundation

#if !os(watchOS)
	import ReachabilitySwift
#endif


internal final class RequestManager {

	internal typealias Delegate = _RequestManagerDelegate

	private var currentFailureCount = 0
	private var currentRequest: NSURL?
	private var pendingTask: NSURLSessionDataTask?
	private var sendNextRequestTimer: NSTimer?
	private let urlSession: NSURLSession

	#if !os(watchOS)
	private let reachability: Reachability?
	private var sendingInterruptedBecauseUnreachable = false
	#endif

	internal private(set) var queue = [NSURL]()
	internal private(set) var started = false

	internal weak var delegate: Delegate?


	internal init(queueLimit: Int) {
		checkIsOnMainThread()

		self.queueLimit = queueLimit
		self.urlSession = RequestManager.createUrlSession()

		#if !os(watchOS)
		do {
			reachability = try Reachability.reachabilityForInternetConnection()
		}
		catch let error {
			logInfo("Cannot check for internet connectivity: \(error)")
			reachability = nil
		}

		reachability?.whenReachable = { [weak self] reachability in
			logDebug("Internet is reachable again!")

			reachability.stopNotifier()
			self?.sendNextRequest()
		}
		#endif
	}


	#if !os(watchOS)
	deinit {
		reachability?.stopNotifier()
	}
	#endif


	private func cancelCurrentRequest() {
		checkIsOnMainThread()

		guard let pendingTask = pendingTask else {
			return
		}

		pendingTask.cancel()

		self.currentRequest = nil
		self.currentFailureCount = 0
		self.pendingTask = nil
	}


	internal func clearPendingRequests() {
		checkIsOnMainThread()

		logInfo("Clearing queue of \(queue.count) requests.")

		queue.removeAll()
	}


	internal static func createUrlSession() -> NSURLSession {
		let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
		configuration.HTTPCookieAcceptPolicy = .Never
		configuration.HTTPShouldSetCookies = false
		configuration.URLCache = nil
		configuration.URLCredentialStorage = nil
		configuration.requestCachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

		let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
		session.sessionDescription = "Webtrekk Tracking"

		return session
	}


	internal func enqueueRequest(request: NSURL, maximumDelay: NSTimeInterval) {
		checkIsOnMainThread()

		if queue.count >= queueLimit {
			logWarning("Too many requests in queue. Dropping oldest one.")

			queue.removeFirst()
		}

		queue.append(request)

		logInfo("Queued: \(request)")

		sendNextRequest(maximumDelay: maximumDelay)
	}


	internal func fetch(url url: NSURL, completion: (NSData?, Error?) -> Void) -> NSURLSessionDataTask {
		checkIsOnMainThread()

		let task = urlSession.dataTaskWithURL(url) { data, response, error in
			if let error = error {
				let retryable: Bool
				let isCompletelyOffline: Bool

				switch error.code {
				case NSURLErrorBadServerResponse,
				     NSURLErrorCallIsActive,
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

				switch error.code {
				case NSURLErrorCallIsActive,
				     NSURLErrorDataNotAllowed,
				     NSURLErrorInternationalRoamingOff,
				     NSURLErrorNotConnectedToInternet:

					isCompletelyOffline = true

				default:
					isCompletelyOffline = false
				}

				completion(nil, Error(message: error.localizedDescription, isTemporary: retryable, isCompletelyOffline: isCompletelyOffline, underlyingError: error))
				return
			}

			guard let response = response as? NSHTTPURLResponse else {
				completion(nil, Error(message: "No Response", isTemporary: false))
				return
			}
			guard !(500 ... 599).contains(response.statusCode) else {
				completion(nil, Error(message: "HTTP \(response.statusCode)", isTemporary: true))
				return
			}
			guard (200 ... 299).contains(response.statusCode), let data = data else {
				completion(nil, Error(message: "HTTP \(response.statusCode)", isTemporary: false))
				return
			}

			completion(data, nil)
		}
		task.resume()
		
		return task
	}


	private func maximumNumberOfFailures(with error: Error) -> Int {
		checkIsOnMainThread()

		if error.isCompletelyOffline {
			return 60
		}
		else {
			return 10
		}
	}


	internal func prependRequests(requests: [NSURL]) {
		checkIsOnMainThread()

		queue.insertContentsOf(requests, at: 0)
		
		removeRequestsExceedingQueueLimit()
	}


	internal var queueLimit: Int {
		didSet {
			checkIsOnMainThread()

			precondition(queueLimit > 0)

			removeRequestsExceedingQueueLimit()
		}
	}


	internal var queueSize: Int {
		checkIsOnMainThread()

		return queue.count
	}


	private func removeRequestsExceedingQueueLimit() {
		checkIsOnMainThread()

		if queueLimit < queue.count {
			queue = Array(queue[(queue.count - queueLimit - 1) ..< queue.count])
		}
	}


	internal func sendAllRequests() {
		checkIsOnMainThread()

		sendNextRequest()
	}


	private func sendNextRequest() {
		checkIsOnMainThread()

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

		#if !os(watchOS)
			if let reachability = reachability {
				guard reachability.isReachable() else {
					if !sendingInterruptedBecauseUnreachable {
						sendingInterruptedBecauseUnreachable = true

						logDebug("Internet is unreachable. Pausing requests.")

						do {
							try reachability.startNotifier()
						}
						catch let error {
							logError("Cannot listen for reachability events: \(error)")
						}
					}

					return
				}

				sendingInterruptedBecauseUnreachable = false
				reachability.stopNotifier()
			}
		#endif

		let url = queue[0]

		if url != currentRequest {
			currentFailureCount = 0
			currentRequest = url
		}

		logDebug("Sending: \(url)")

		pendingTask = fetch(url: url) { data, error in
			self.pendingTask = nil

			if let error = error {
				guard error.isTemporary else {
					logError("Request \(url) failed and will not be retried: \(error)")

					self.currentFailureCount = 0
					self.currentRequest = nil
					self.queue.removeFirstEqual(url)

					self.delegate?.requestManager(self, didFailToSendRequest: url, error: error)
					return
				}
				guard self.currentFailureCount < self.maximumNumberOfFailures(with: error) else {
					logError("Request \(url) failed and will no longer be retried: \(error)")

					self.currentFailureCount = 0
					self.currentRequest = nil
					self.queue.removeFirstEqual(url)

					self.delegate?.requestManager(self, didFailToSendRequest: url, error: error)
					return
				}

				let retryDelay = Double(self.currentFailureCount * 5)
				logDebug("Request \(url) failed temporarily and will be retried in \(retryDelay) seconds: \(error)")

				self.currentFailureCount += 1
				self.sendNextRequest(maximumDelay: retryDelay)
				return
			}

			self.currentFailureCount = 0
			self.currentRequest = nil
			self.queue.removeFirstEqual(url)

			logDebug("Sent: \(url)")

			self.delegate?.requestManager(self, didSendRequest: url)

			self.sendNextRequest()
		}
	}


	private func sendNextRequest(maximumDelay maximumDelay: NSTimeInterval) {
		checkIsOnMainThread()

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
		checkIsOnMainThread()

		guard !started else {
			logWarning("Cannot start RequestManager which was already started.")
			return
		}

		started = true

		sendNextRequest()
	}


	internal func stop() {
		checkIsOnMainThread()

		guard started else {
			logWarning("Cannot stop RequestManager which wasn't started.")
			return
		}

		started = false

		sendNextRequestTimer?.invalidate()
		sendNextRequestTimer = nil

		#if !os(watchOS)
			sendingInterruptedBecauseUnreachable = false
			reachability?.stopNotifier()
		#endif
	}



	internal struct Error: ErrorType {

		internal var isCompletelyOffline: Bool
		internal var isTemporary: Bool
		internal var message: String
		internal var underlyingError: ErrorType?


		internal init(message: String, isTemporary: Bool, isCompletelyOffline: Bool = false, underlyingError: ErrorType? = nil) {
			self.isCompletelyOffline = isCompletelyOffline
			self.isTemporary = isTemporary
			self.message = message
			self.underlyingError = underlyingError
		}
	}
}


internal protocol _RequestManagerDelegate: class {

	func requestManager (requestManager: RequestManager, didSendRequest request: NSURL)
	func requestManager (requestManager: RequestManager, didFailToSendRequest request: NSURL, error: RequestManager.Error)
}
