import Foundation

internal func delay(seconds: Int, closure: ()->()) {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), closure)
}

internal func synchronized<ReturnType>(object: AnyObject, @noescape closure: Void throws -> ReturnType) rethrows -> ReturnType {
	objc_sync_enter(object)
	defer {
		objc_sync_exit(object)
	}

	return try closure()
}

internal final class EmptyObject {
	internal init() {}
}