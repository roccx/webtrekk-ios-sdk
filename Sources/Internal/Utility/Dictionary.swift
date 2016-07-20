internal extension Dictionary {

	@warn_unused_result
	internal func merged(over other: [Key: Value]) -> [Key: Value] {
		var merged = other
		for (key, value) in self {
			merged[key] = value
		}
		return merged
	}


	@warn_unused_result
	internal func merged(over other: [Key: Value]?) -> [Key: Value] {
		guard let other = other else {
			return self
		}

		return merged(over: other)
	}
}


internal extension _Optional where Wrapped == Dictionary<Int, TrackingValue> {

	@warn_unused_result
	internal func merged(over other: Wrapped?) -> Wrapped? {
		guard let value = value else {
			return other
		}

		return value.merged(over: other)
	}
}
