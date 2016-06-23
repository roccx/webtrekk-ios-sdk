public struct ActionProperties {

	public var details: Set<IndexedProperty>?
	public var name: String


	public init(
		name: String,
		details: Set<IndexedProperty>? = nil)
	{
		self.details = details
		self.name = name
	}

	
	@warn_unused_result
	internal func merged(with other: ActionProperties) -> ActionProperties {
		return ActionProperties(
			name:    name,
			details: details ?? other.details
		)
	}
}
