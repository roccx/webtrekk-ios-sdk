// used like @syncronized as known from objc

import Foundation

internal func with(queue: dispatch_queue_t, f: Void -> Void) {
	dispatch_sync(queue, f)
}
