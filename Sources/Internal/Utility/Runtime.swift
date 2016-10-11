import ObjectiveC


private func class_getInstanceMethodIgnoringSupertypes(_ clazz: AnyClass, _ name: Selector) -> Method? {
	let method = class_getInstanceMethod(clazz, name)

	if let superclass = class_getSuperclass(clazz) {
		let superclassMethod = class_getInstanceMethod(superclass, name)
		guard superclassMethod != method else {
			return nil
		}
	}

	return method!
}


internal func swizzleMethod(ofType type: AnyClass, fromSelector: Selector, toSelector: Selector) -> Bool {
	precondition(fromSelector != toSelector)

	let fromMethod = class_getInstanceMethodIgnoringSupertypes(type, fromSelector)
	guard fromMethod != nil else {
		logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since the former is not present in '\(type)'.")
		return false
	}

	let toMethod = class_getInstanceMethodIgnoringSupertypes(type, toSelector)
	guard toMethod != nil else {
		logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since the latter is not present in '\(type)'.")
		return false
	}

	let fromTypePointer = method_getTypeEncoding(fromMethod)
	let toTypePointer = method_getTypeEncoding(toMethod)
	guard fromTypePointer != nil && toTypePointer != nil, let fromType = String(validatingUTF8: fromTypePointer!), let toType = String(validatingUTF8: toTypePointer!) else {
		logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since their type encodings could not be accessed.")
		return false
	}
	guard fromType == toType else {
		logError("Selector '\(fromSelector)' was not swizzled with selector '\(toSelector)' since their type encodings don't match: '\(fromType)' -> '\(toType)'.")
		return false
	}

	method_exchangeImplementations(fromMethod, toMethod)
	return true
}

// functoin add method to class from another class
func addMethodFromAnotherClass(toClass: AnyClass, methodSelector: Selector, fromClass: AnyClass) -> Bool{
    
    //get method object
    
    let method = class_getInstanceMethod(fromClass, methodSelector)
    
    if  method == nil {
        WebtrekkTracking.defaultLogger.logError("can't get method from method selector")
        return false
    }
    
    let methodImpl = method_getImplementation(method)
    let methodTypes = method_getTypeEncoding(method)
    
    if  methodImpl == nil {
        WebtrekkTracking.defaultLogger.logError("can't get method implementation from method")
        return false
    }
    
    if  methodTypes == nil {
        WebtrekkTracking.defaultLogger.logError("can't get method types from method")
        return false
    }
    
    return class_addMethod(toClass, methodSelector, methodImpl, methodTypes)
}
