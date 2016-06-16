import Foundation


public final class Loger {
	internal var enabled = false

	internal init() {
	}

	internal func log(@autoclosure messageClosure: Void throws -> String) rethrows {
		if !enabled {
			return
		}
		NSLog("%@", "\(try messageClosure())")
	}
}


internal protocol Logable {
	var loger: Loger { get }
}

extension Logable {
	func log(@autoclosure messageClosure: Void throws -> String) rethrows {
		try loger.log(messageClosure())
	}
}
