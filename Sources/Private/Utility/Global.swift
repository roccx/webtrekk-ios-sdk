import Foundation


internal typealias Closure = () -> Void


internal func lazyPlaceholder<T>() -> T {
	fatalError("Lazy variable accessed before being initialized.")
}


internal func logDebug(@autoclosure message: () -> String) {
	WebtrekkTracking.logger.logDebug(message)
}


internal func logError(@autoclosure message: () -> String) {
	WebtrekkTracking.logger.logError(message)
}


internal func logInfo(@autoclosure message: () -> String) {
	WebtrekkTracking.logger.logInfo(message)
}


internal func logWarning(@autoclosure message: () -> String) {
	WebtrekkTracking.logger.logWarning(message)
}


internal func onMainQueue(closure: Closure) {
	dispatch_async(dispatch_get_main_queue(), closure)
}
