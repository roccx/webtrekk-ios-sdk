import Foundation


internal extension SequenceType {

	@warn_unused_result
	internal func firstMatching(@noescape predicate: Generator.Element throws -> Bool) rethrows -> Generator.Element? {
		for element in self where try predicate(element) {
			return element
		}

		return nil
	}


	@warn_unused_result
	internal func mapNotNil<T>(@noescape transform: (Generator.Element) throws -> T?) rethrows -> [T] {
		var result = [T]()
		for element in self {
			guard let mappedElement = try transform(element) else {
				continue
			}

			result.append(mappedElement)
		}

		return result
	}
}


internal extension SequenceType where Generator.Element: _Optional {

	@warn_unused_result
	internal func filterNonNil() -> [Generator.Element.Wrapped] {
		var result = Array<Generator.Element.Wrapped>()
		for element in self {
			guard let element = element.value else {
				continue
			}

			result.append(element)
		}

		return result
	}
}
