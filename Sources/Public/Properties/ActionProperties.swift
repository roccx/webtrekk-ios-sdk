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
}
