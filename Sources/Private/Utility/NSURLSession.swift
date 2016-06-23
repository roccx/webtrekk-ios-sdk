import Foundation


internal extension NSURLSession {

	// FIXME
	static func defaultSession() -> NSURLSession {
		return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
		                    delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
	}
}