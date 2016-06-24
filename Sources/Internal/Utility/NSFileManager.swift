import Foundation


internal extension NSFileManager {

	@nonobjc
	internal func itemExistsAtURL(url: NSURL) -> Bool {
		guard url.fileURL, let path = url.path else {
			return false
		}

		return fileExistsAtPath(path)
	}
}
