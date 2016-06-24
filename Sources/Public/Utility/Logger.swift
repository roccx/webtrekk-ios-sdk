import Foundation


public extension Webtrekk {

	public typealias Logger = _Logger

	public static let defaultLogger = DefaultLogger()
	public static var logger: Logger = Webtrekk.defaultLogger



	public final class DefaultLogger: Logger {

		public var enabled = true
		public var minimumLevel = LogLevel.warning


		public func log(@autoclosure message message: () -> String, level: LogLevel) {
			guard enabled && level.rawValue >= minimumLevel.rawValue else {
				return
			}

			NSLog("%@", "[Webtrekk] [\(level.title)] \(message())")
		}
	}


	public enum LogLevel: Int {

		case debug   = 1
		case info    = 2
		case warning = 3
		case error   = 4


		private var title: String {
			switch (self) {
			case .debug:   return "Debug"
			case .info:    return "Info"
			case .warning: return "Warning"
			case .error:   return "ERROR"
			}
		}
	}
}


public protocol _Logger: class {

	func log (@autoclosure message message: () -> String, level: Webtrekk.LogLevel)
}


public extension _Logger {

	public func logDebug(@autoclosure message: () -> String) {
		log(message: message, level: .debug)
	}


	public func logError(@autoclosure message: () -> String) {
		log(message: message, level: .error)
	}


	public func logInfo(@autoclosure message: () -> String) {
		log(message: message, level: .info)
	}


	public func logWarning(@autoclosure message: () -> String) {
		log(message: message, level: .warning)
	}
}
