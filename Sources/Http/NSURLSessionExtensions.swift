import Foundation

extension NSURLSession: UrlSessionProtocol {
	public func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult)	-> UrlSessionDataTaskProtocol {
		return (dataTaskWithURL(url, completionHandler: completionHandler)
			as NSURLSessionDataTask) as UrlSessionDataTaskProtocol
	}
}

extension NSURLSession {
	static func defaultSession() -> NSURLSession {
		return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("WT"),
		                    delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
	}
}

extension NSURLSessionDataTask: UrlSessionDataTaskProtocol {}
