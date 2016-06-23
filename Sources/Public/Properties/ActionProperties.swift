public struct ActionProperties {

	public var categories: Set<Category>?
	public var name: String


	public init(
		name: String,
		categories: Set<Category>? = nil)
	{
		self.categories = categories
		self.name = name
	}

	
	@warn_unused_result
	internal func merged(with other: ActionProperties) -> ActionProperties {
		return ActionProperties(
			name:       name,
			categories: categories ?? other.categories
		)
	}
}
