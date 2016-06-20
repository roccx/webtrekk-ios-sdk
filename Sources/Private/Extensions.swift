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

}



internal extension Dictionary {
	mutating func updateValues(fromDictionary: [Key : Value]) {
		for (key, value) in fromDictionary {
			updateValue(value, forKey: key)
		}
	}
}