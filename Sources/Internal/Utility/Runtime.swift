//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by arsen.vartbaronov on 14/09/16.
//

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

// function adds method to class from another class
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
