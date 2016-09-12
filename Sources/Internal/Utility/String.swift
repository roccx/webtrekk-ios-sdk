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
    
    //check if string is matched to expression
    internal func isMatchForRegularExpression(expression: String) -> Bool?{
    
       do {
            let regularExpression = try NSRegularExpression(pattern: expression, options: [])
            return regularExpression.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, utf16.count)) == 1
       }
            catch let error {
                WebtrekkTracking.defaultLogger.logError("Incorrect regular expression \(expression)")
                return nil
       }
    }


	internal var nonEmpty: String? {
		if isEmpty {
			return nil
		}

		return self
	}


	internal var simpleDescription: String {
		return "\"\(self)\""
	}
    
    internal func isValidURL() -> Bool {
    
    if let url = NSURL(string: self), let host = url.host{
            return true
        } else {
            return false
        }
    }
}


internal extension _Optional where Wrapped == String {

	internal var simpleDescription: String {
		return value?.simpleDescription ?? "<nil>"
	}
}
