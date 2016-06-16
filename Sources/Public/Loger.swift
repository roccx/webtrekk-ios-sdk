import Foundation


public protocol Logger {
	var enabled: Bool { get set }
	func log (@autoclosure messageClosure: Void throws -> String) rethrows
	func log (@autoclosure messageClosure: Void throws -> String, logLevel: LogLevel) rethrows
}

public enum LogLevel: Int {
	case Debug = 1
	case Warn  = 2
	case Error = 3
}

public final class DefaultLogger: Logger {
	public var enabled = false
	public var currentLogLevel = LogLevel.Debug
	public init() {
	}

	public func log(@autoclosure messageClosure: Void throws -> String) rethrows {
		try log(messageClosure, logLevel: LogLevel.Debug)
	}

	public func log(@autoclosure messageClosure: Void throws -> String, logLevel: LogLevel) rethrows {
		if !enabled || currentLogLevel.rawValue > logLevel.rawValue {
			return
		}
		NSLog("%@", "\(try messageClosure())")
	}
}


internal protocol Logable {
	var logger: Logger { get }
}

extension Logable {
	func log(@autoclosure messageClosure: Void throws -> String) rethrows {
		try logger.log(messageClosure())
	}

	func logW(@autoclosure messageClosure: Void throws -> String) rethrows {
		try logger.log(messageClosure(), logLevel: .Warn)
	}

	func logE(@autoclosure messageClosure: Void throws -> String) rethrows {
		try logger.log(messageClosure(), logLevel: .Error)
	}
}
