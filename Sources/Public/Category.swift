public struct Category {

	public var index: Int
	public var name: String


	public init(index: Int, name: String) {
		self.index = index
		self.name = name
	}
}


extension Category: Hashable {

	public var hashValue: Int {
		return index.hashValue
	}
}


public func == (a: Category, b: Category) -> Bool {
	return a.index == b.index
}
