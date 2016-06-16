import UIKit


extension NSURL {

	@nonobjc
	public func URLByAppendingQueryItems(queryItems: [NSURLQueryItem]) -> NSURL? {
		guard !queryItems.isEmpty else {
			return self
		}

		guard let urlComponents = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else {
			return nil
		}

		urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

		return urlComponents.URL
	}


	@nonobjc
	public func URLQueryItems() -> [NSURLQueryItem] {
		guard let urlComponents = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else {
			return []
		}

		return urlComponents.queryItems ?? []
	}
}

extension NSURLQueryItem {

	internal convenience init(name: String, values: [String]) {
		self.init(name: name, value: values.joinWithSeparator(";"))
	}


	internal convenience init(name: ParameterName, value: String?) {
		self.init(name: name.rawValue, value: value)
	}


	internal convenience init(name: ParameterName, withIndex index: Int, value: String) {
		self.init(name: "\(name.rawValue)\(index)", value: value)
	}

}


internal extension SequenceType where Generator.Element: _Optional {

	@warn_unused_result
	internal func filterNonNil() -> [Generator.Element.Wrapped] {
		var result = Array<Generator.Element.Wrapped>()
		for element in self {
			guard let element = element.value else {
				continue
			}

			result.append(element)
		}

		return result
	}
}


extension Array {
	internal mutating func enqueue (value: Element) {
		self.append(value)
	}


	internal mutating func dequeue () -> Element? {
		guard !self.isEmpty else {
			return nil
		}
		return self.removeFirst()
	}


	internal func peek() -> Element? {
		guard !self.isEmpty, let firstItem = self.first else {
			return nil
		}
		return firstItem
	}
}


internal protocol _Optional: NilLiteralConvertible {

	associatedtype Wrapped

	init()
	init(_ some: Wrapped)

	@warn_unused_result
	func map<U>(@noescape f: (Wrapped) throws -> U) rethrows -> U?

	@warn_unused_result
	func flatMap<U>(@noescape f: (Wrapped) throws -> U?) rethrows -> U?
}


extension Optional: _Optional {}


internal extension _Optional {

	internal var value: Wrapped? {
		return map { $0 }
	}
}


internal extension NSURLSession {
	static func defaultSession() -> NSURLSession {
		return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
		                    delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
	}

	internal static func get(url: NSURL, session: NSURLSession = NSURLSession.defaultSession(), logger: Logger? = nil, completion: (NSData?, ErrorType?) -> Void) {
		let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
			let recoverable: Bool
			if let error = error {
				switch error.code {
				case NSURLErrorBadServerResponse, NSURLErrorCallIsActive, NSURLErrorCancelled, NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDataNotAllowed, NSURLErrorDNSLookupFailed, NSURLErrorInternationalRoamingOff, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut, NSURLErrorZeroByteResource:
					logger?.log("Error \"\(error.localizedDescription)\" occured during request of \(url), will be retried.", logLevel: .Error)
					recoverable = true
				default:
					logger?.log("Error \"\(error.localizedDescription)\" occured during request of \(url), will not be retried.", logLevel: .Error)
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
public extension UIDevice {
	var modelIdentifier: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 where value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		return identifier
	}
}

public enum Error: ErrorType {
	case NetworkError(recoverable: Bool)
}


internal extension Dictionary {
	mutating func updateValues(fromDictionary: [Key : Value]) {
		for (key, value) in fromDictionary {
			updateValue(value, forKey: key)
		}
	}
}