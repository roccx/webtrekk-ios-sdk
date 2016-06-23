import Foundation


internal extension NSRange {

	internal init(forString string: String) {
		self.init(range: string.startIndex ..< string.endIndex, inString: string)
	}


	internal init(range: Range<String.Index>?, inString string: String) {
		if let range = range {
			let location = NSRange.locationForIndex(range.startIndex, inString: string)
			let endLocation = NSRange.locationForIndex(range.endIndex, inString: string)

			self.init(location: location, length: location.distanceTo(endLocation))
		}
		else {
			self.init(location: NSNotFound, length: 0)
		}
	}


	@warn_unused_result
	internal func endIndexInString(string: String) -> String.Index? {
		return NSRange.indexForLocation(NSMaxRange(self), inString: string)
	}


	private static func indexForLocation(location: Int, inString string: String) -> String.Index? {
		if location == NSNotFound {
			return nil
		}

		return string.utf16.startIndex.advancedBy(location, limit:string.utf16.endIndex).samePositionIn(string)
	}


	private static func locationForIndex(index: String.Index, inString string: String) -> Int {
		return string.utf16.startIndex.distanceTo(index.samePositionIn(string.utf16))
	}


	@warn_unused_result
	internal func rangeInString(string: String) -> Range<String.Index>? {
		if let startIndex = startIndexInString(string), endIndex = endIndexInString(string) {
			return startIndex ..< endIndex
		}

		return nil
	}


	@warn_unused_result
	internal func startIndexInString(string: String) -> String.Index? {
		return NSRange.indexForLocation(location, inString: string)
	}
}
