import Foundation

public protocol HttpClient {
	var session: UrlSessionProtocol { get }
	func get(url: NSURL, completion: HTTPResult)
}

public typealias HTTPResult = (NSData?, ErrorType?) -> Void
public typealias DataTaskResult = (NSData?, NSURLResponse?, NSError?) -> Void


public enum Error: ErrorType {
	case NetworkError(recoverable: Bool)
}

public protocol UrlSessionProtocol {
	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult) -> UrlSessionDataTaskProtocol
}

public protocol UrlSessionDataTaskProtocol {
	func resume()
}