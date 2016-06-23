import Foundation


internal typealias Closure = () -> Void
internal var autoTracker: [Webtrekk] = []


public func lazyPlaceholder<T>() -> T {
	fatalError("Lazy variable accessed before being initialized.")
}
