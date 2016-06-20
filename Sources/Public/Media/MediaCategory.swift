public struct MediaCategory {

	public var index: Int
	public var name: String


	public init(index: Int, name: String) {
		self.index = index
		self.name = name
	}
}


extension MediaCategory: Hashable {

	public var hashValue: Int {
		return index.hashValue
	}
}


public func == (a: MediaCategory, b: MediaCategory) -> Bool {
	return a.index == b.index
}
