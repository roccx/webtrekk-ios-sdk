import Foundation


internal typealias Closure = () -> Void


internal func lazyPlaceholder<T>() -> T {
	fatalError("Lazy variable accessed before being initialized.")
}
