internal extension RangeReplaceableCollectionType where Generator.Element: Equatable {

	internal mutating func removeFirstEqual(element: Generator.Element) -> (Index, Generator.Element)? {
		guard let index = indexOf(element) else {
			return nil
		}

		return (index, removeAtIndex(index))
	}
}
