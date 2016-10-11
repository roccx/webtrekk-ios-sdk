//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

import Foundation

#if !os(watchOS)
	import ReachabilitySwift
#endif


internal final class RequestManager {

	internal typealias Delegate = _RequestManagerDelegate

	private var currentFailureCount = 0
	private var currentRequest: URL?
	private var pendingTask: URLSessionDataTask?
	private var sendNextRequestTimer: Timer?
	private let urlSession: URLSession

	#if !os(watchOS)
	private let reachability: Reachability?
	private var sendingInterruptedBecauseUnreachable = false
	#endif

	internal fileprivate(set) var queue = [URL]()
	internal fileprivate(set) var started = false

	internal weak var delegate: Delegate?


	internal init(queueLimit: Int) {
		checkIsOnMainThread()

		self.queueLimit = queueLimit
		self.urlSession = RequestManager.createUrlSession()

		#if !os(watchOS)
        
        reachability = Reachability.init()

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


	fileprivate func cancelCurrentRequest() {
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


	internal static func createUrlSession() -> URLSession {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.httpCookieAcceptPolicy = .never
		configuration.httpShouldSetCookies = false
		configuration.urlCache = nil
		configuration.urlCredentialStorage = nil
		configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

		let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
		session.sessionDescription = "Webtrekk Tracking"

		return session
	}


	internal func enqueueRequest(_ request: URL, maximumDelay: TimeInterval) {
		checkIsOnMainThread()

		if queue.count >= queueLimit {
			logWarning("Too many requests in queue. Dropping oldest one.")

			queue.removeFirst()
		}

		queue.append(request)

		logInfo("Queued: \(request)")

		sendNextRequest(maximumDelay: maximumDelay)
	}


	internal func fetch(url: URL, completion: @escaping (Data?, ConnectionError?) -> Void) -> URLSessionDataTask {
		checkIsOnMainThread()

		let task = urlSession.dataTask(with: url, completionHandler: { data, response, error in
			if let error = error {
				let retryable: Bool
				let isCompletelyOffline: Bool

				switch (error as NSError).code {
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

				switch (error as NSError).code {
				case NSURLErrorCallIsActive,
				     NSURLErrorDataNotAllowed,
				     NSURLErrorInternationalRoamingOff,
				     NSURLErrorNotConnectedToInternet:

					isCompletelyOffline = true

				default:
					isCompletelyOffline = false
				}

				completion(nil, ConnectionError(message: error.localizedDescription, isTemporary: retryable, isCompletelyOffline: isCompletelyOffline, underlyingError: error))
				return
			}

			guard let response = response as? HTTPURLResponse else {
				completion(nil, ConnectionError(message: "No Response", isTemporary: false))
				return
			}
			guard !(500 ... 599).contains(response.statusCode) else {
				completion(nil, ConnectionError(message: "HTTP \(response.statusCode)", isTemporary: true))
				return
			}
			guard (200 ... 299).contains(response.statusCode), let data = data else {
				completion(nil, ConnectionError(message: "HTTP \(response.statusCode)", isTemporary: false))
				return
			}

			completion(data, nil)
		}) 
		task.resume()
		
		return task
	}


	fileprivate func maximumNumberOfFailures(with error: ConnectionError) -> Int {
		checkIsOnMainThread()

		if error.isCompletelyOffline {
			return 60
		}
		else {
			return 10
		}
	}


	internal func prependRequests(_ requests: [URL]) {
		checkIsOnMainThread()

		queue.insert(contentsOf: requests, at: 0)
		
		removeRequestsExceedingQueueLimit()
	}


	internal var queueLimit: Int {
		didSet {
			checkIsOnMainThread()

			precondition(queueLimit > 0)

			removeRequestsExceedingQueueLimit()
		}
	}


	fileprivate func removeRequestsExceedingQueueLimit() {
		checkIsOnMainThread()

		if queueLimit < queue.count {
			queue = Array(queue[(queue.count - queueLimit - 1) ..< queue.count])
		}
	}


	internal func sendAllRequests() {
		checkIsOnMainThread()

		sendNextRequest()
	}


	fileprivate func sendNextRequest() {
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
				guard reachability.isReachable else {
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
					let _ = self.queue.removeFirstEqual(url)

					self.delegate?.requestManager(self, didFailToSendRequest: url, error: error)
					return
				}
				guard self.currentFailureCount < self.maximumNumberOfFailures(with: error) else {
					logError("Request \(url) failed and will no longer be retried: \(error)")

					self.currentFailureCount = 0
					self.currentRequest = nil
					let _ = self.queue.removeFirstEqual(url)

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
			let _ = self.queue.removeFirstEqual(url)

			logDebug("Sent: \(url)")

			self.delegate?.requestManager(self, didSendRequest: url)

			self.sendNextRequest()
		}
	}


	fileprivate func sendNextRequest(maximumDelay: TimeInterval) {
		checkIsOnMainThread()

		guard !queue.isEmpty else {
			return
		}
		guard maximumDelay > 0 else {
			sendAllRequests()
			return
		}

		if let sendNextRequestTimer = sendNextRequestTimer {
			let fireDate = Date(timeIntervalSinceNow: maximumDelay)
			if fireDate.compare(sendNextRequestTimer.fireDate) == ComparisonResult.orderedAscending {
				sendNextRequestTimer.fireDate = fireDate
			}
		}
		else {
			sendNextRequestTimer = Timer.scheduledTimerWithTimeInterval(maximumDelay) {
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



	internal struct ConnectionError: Error {

		internal var isCompletelyOffline: Bool
		internal var isTemporary: Bool
		internal var message: String
		internal var underlyingError: Error?


		internal init(message: String, isTemporary: Bool, isCompletelyOffline: Bool = false, underlyingError: Error? = nil) {
			self.isCompletelyOffline = isCompletelyOffline
			self.isTemporary = isTemporary
			self.message = message
			self.underlyingError = underlyingError
		}
	}
}


internal protocol _RequestManagerDelegate: class {

	func requestManager (_ requestManager: RequestManager, didSendRequest request: URL)
	func requestManager (_ requestManager: RequestManager, didFailToSendRequest request: URL, error: RequestManager.ConnectionError)
}
