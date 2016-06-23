public struct IndexedProperty {

	public var index: Int
	public var value: String


	public init(index: Int, value: String) {
		self.index = index
		self.value = value
	}
}


extension IndexedProperty: Hashable {

	public var hashValue: Int {
		return index.hashValue
	}
}


public func == (a: IndexedProperty, b: IndexedProperty) -> Bool {
	return a.index == b.index
}
