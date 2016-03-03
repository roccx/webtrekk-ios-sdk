import Foundation

internal class HttpClient {
	private let session: UrlSessionProtocol

	internal init(session: UrlSessionProtocol = NSURLSession.sharedSession()) {
		self.session = session
	}

	internal func get(url: NSURL, completion: HTTPResult) {
		let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
			let recoverable: Bool
			if let error = error {
				switch error.code {
				case NSURLErrorBadServerResponse, NSURLErrorCallIsActive, NSURLErrorCancelled, NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDataNotAllowed, NSURLErrorDNSLookupFailed, NSURLErrorInternationalRoamingOff, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut, NSURLErrorZeroByteResource:
					recoverable = true
				default:
					recoverable = false
				}
				completion(nil, Error.NetworkError(recoverable: recoverable))
			} else if let response = response as? NSHTTPURLResponse where 200...299 ~= response.statusCode {
				completion(data, nil)
			} else {
				completion(nil, Error.NetworkError(recoverable: false))
			}
		}
		task.resume()
	}

}

enum Error: ErrorType {
	case NetworkError(recoverable: Bool)
}

typealias HTTPResult = (NSData?, ErrorType?) -> Void
typealias DataTaskResult = (NSData?, NSURLResponse?, NSError?) -> Void

internal protocol UrlSessionProtocol {

	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult) -> UrlSessionDataTaskProtocol
}

extension NSURLSession: UrlSessionProtocol {
	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult)	-> UrlSessionDataTaskProtocol {
		return (dataTaskWithURL(url, completionHandler: completionHandler)
			as NSURLSessionDataTask) as UrlSessionDataTaskProtocol
	}
}

internal class MockUrlSession: UrlSessionProtocol {
	var nextDataTask = MockUrlSessionDataTask()
	private(set) var lastUrl: NSURL?

	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult) -> UrlSessionDataTaskProtocol {
		lastUrl = url
		return nextDataTask
	}
}


extension NSURLSession {
	static func defaultSession() -> NSURLSession {
		return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
		                    delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
	}
}


internal protocol UrlSessionDataTaskProtocol {
	func resume()
}

extension NSURLSessionDataTask: UrlSessionDataTaskProtocol {}

internal class MockUrlSessionDataTask: UrlSessionDataTaskProtocol {
	private(set) var resumeWasCalled = false

	func resume() {
		resumeWasCalled = true
	}
}