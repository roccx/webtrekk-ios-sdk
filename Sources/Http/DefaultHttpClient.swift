import Foundation

internal final class DefaultHttpClient: HttpClient {
	internal let session: UrlSessionProtocol
	internal var loger: Loger?
	internal init(session: UrlSessionProtocol = NSURLSession.sharedSession(), loger: Loger? = nil) {
		self.session = session
		self.loger = loger
	}

	internal func get(url: NSURL, completion: HTTPResult) {
		let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
			let recoverable: Bool
			if let error = error {
				switch error.code {
				case NSURLErrorBadServerResponse, NSURLErrorCallIsActive, NSURLErrorCancelled, NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDataNotAllowed, NSURLErrorDNSLookupFailed, NSURLErrorInternationalRoamingOff, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut, NSURLErrorZeroByteResource:
					self.loger?.log("Error \"\(error.localizedDescription)\" occured during request of \(url), will be retried.")
					recoverable = true
				default:
					self.loger?.log("Error \"\(error.localizedDescription)\" occured during request of \(url), will not be retried.")
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