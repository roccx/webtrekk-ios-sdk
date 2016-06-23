import Foundation


extension Webtrekk {

	public typealias Logger = _Logger


	public enum LogLevel: Int {

		case Info    = 1
		case Warning = 2
		case Error   = 3
	}
}


public protocol _Logger: class {

	func log (@autoclosure message message: () -> String, level: Webtrekk.LogLevel)
}


public extension _Logger {

	public func logError(@autoclosure message: () -> String) {
		log(message: message, level: .Error)
	}


	public func logInfo(@autoclosure message: () -> String) {
		log(message: message, level: .Info)
	}


	public func logWarning(@autoclosure message: () -> String) {
		log(message: message, level: .Warning)
	}
}
