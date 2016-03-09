import Foundation

internal final class DefaultHttpClient: HttpClient {
	internal let session: UrlSessionProtocol

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