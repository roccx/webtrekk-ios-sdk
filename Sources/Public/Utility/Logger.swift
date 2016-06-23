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

		case info    = 1
		case warning = 2
		case error   = 3


		private var title: String {
			switch (self) {
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
