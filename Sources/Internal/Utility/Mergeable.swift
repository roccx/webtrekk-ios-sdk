import Foundation


internal protocol Mergeable {

	@warn_unused_result
	func merged(over other: Self) -> Self
}


internal extension Mergeable {

	@warn_unused_result
	internal func merged(over other: Self?) -> Self {
		guard let other = other else {
			return self
		}

		return merged(over: other)
	}
}


internal extension _Optional where Wrapped: Mergeable {

	@warn_unused_result
	internal func merged(over other: Wrapped?) -> Wrapped? {
		guard let value = value else {
			return other
		}

		return value.merged(over: other)
	}
}
