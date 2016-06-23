import ObjectiveC


private func class_getInstanceMethodIgnoringSupertypes(clazz: AnyClass, _ name: Selector) -> Method {
	let method = class_getInstanceMethod(clazz, name)

	if let superclass = class_getSuperclass(clazz) {
		let superclassMethod = class_getInstanceMethod(superclass, name)
		guard superclassMethod != method else {
			return nil
		}
	}

	return method
}


public func swizzleMethod(ofType type: AnyClass, fromSelector: Selector, toSelector: Selector) -> Bool {
	precondition(fromSelector != toSelector)

	let fromMethod = class_getInstanceMethodIgnoringSupertypes(type, fromSelector)
	guard fromMethod != nil else {
		Webtrekk.defaultLogger.logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since the former is not present in '\(type)'.")
		return false
	}

	let toMethod = class_getInstanceMethodIgnoringSupertypes(type, toSelector)
	guard toMethod != nil else {
		Webtrekk.defaultLogger.logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since the latter is not present in '\(type)'.")
		return false
	}

	let fromTypePointer = method_getTypeEncoding(fromMethod)
	let toTypePointer = method_getTypeEncoding(toMethod)
	guard fromTypePointer != nil && toTypePointer != nil, let fromType = String.fromCString(fromTypePointer), toType = String.fromCString(toTypePointer) else {
		Webtrekk.defaultLogger.logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since their type encodings could not be accessed.")
		return false
	}
	guard fromType == toType else {
		Webtrekk.defaultLogger.logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since their type encodings don't match: '\(fromType)' -> '\(toType)'.")
		return false
	}

	method_exchangeImplementations(fromMethod, toMethod)
	return true
}
