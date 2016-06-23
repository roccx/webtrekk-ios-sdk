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


	private static func locationForIndex(index: String.Index, inString string: String) -> Int {
		return string.utf16.startIndex.distanceTo(index.samePositionIn(string.utf16))
	}
}
