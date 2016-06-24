import Foundation


internal typealias Closure = () -> Void


internal func checkIsOnMainThread(function function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
	guard !NSThread.isMainThread() else {
		return
	}

	var file = String(file)
	if let range = file.rangeOfString("/", options: .BackwardsSearch, range: nil, locale: nil) {
		file = file[range.startIndex.advancedBy(1) ..< file.endIndex]
	}

	logError("[\(file):\(line)] \(function) must be called on the main thread!")
}


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


internal func onMainQueue(synchronousIfPossible synchronousIfPossible: Bool = false, closure: Closure) {
	guard !synchronousIfPossible || !NSThread.isMainThread() else {
		closure()
		return
	}

	dispatch_async(dispatch_get_main_queue(), closure)
}
