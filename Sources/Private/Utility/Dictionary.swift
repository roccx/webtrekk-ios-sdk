internal extension Dictionary {

	@warn_unused_result
	internal func merged(over other: [Key: Value]) -> [Key: Value] {
		var merged = other
		for (key, value) in self {
			merged[key] = value
		}
		return merged
	}
}
