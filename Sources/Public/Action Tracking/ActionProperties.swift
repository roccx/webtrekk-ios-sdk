public struct ActionProperties {

	public var category: Set<Category> = []
	public var name: String
	public var session: Set<Category> = []


	public init(name: String) {
		self.name = name
	}
}
