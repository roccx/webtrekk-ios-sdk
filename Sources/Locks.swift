// used like @syncronized as known from objc

import Foundation

internal func with(queue: dispatch_queue_t, f: Void -> Void) {
	dispatch_sync(queue, f)
}

// easy delay func

internal func delay(seconds: Int, closure: ()->()) {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), closure)
}