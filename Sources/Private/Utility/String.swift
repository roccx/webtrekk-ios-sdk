import Foundation


internal extension String {

	@warn_unused_result
	internal func firstMatchForRegularExpression(regularExpression: NSRegularExpression) -> [String]? {
		guard let match = regularExpression.firstMatchInString(self, options: [], range: NSMakeRange(0, utf16.count)) else {
			return nil
		}

		return (0 ..< match.numberOfRanges).map { self[match.rangeAtIndex($0).rangeInString(self)!] }
	}


	@warn_unused_result
	internal func firstMatchForRegularExpression(regularExpressionPattern: String) -> [String]? {
		do {
			let regularExpression = try NSRegularExpression(pattern: regularExpressionPattern, options: [])
			return firstMatchForRegularExpression(regularExpression)
		}
		catch let error {
			fatalError("Invalid regular expression pattern: \(error)")
		}
	}


	internal var nonEmpty: String? {
		if isEmpty {
			return nil
		}

		return self
	}
}
