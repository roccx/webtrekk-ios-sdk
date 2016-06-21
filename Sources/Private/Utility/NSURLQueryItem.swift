import Foundation



internal extension NSURLQueryItem {

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
