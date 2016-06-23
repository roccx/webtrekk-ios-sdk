import Foundation


public enum Webtrekk {

	public static let version = "4.0"


	public static let defaultLogger = DefaultLogger()
	public static var logger: Logger = Webtrekk.defaultLogger

	
	public static func tracker(configurationFile configurationFile: NSURL) throws -> Tracker {
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)'")
		}

		do {
			return tracker(configuration: try XmlTrackerConfigurationParser().parse(xml: configurationData))
		}
		catch let error {
			fatalError("Cannot load Webtrekk configuration file '\(configurationFile)': \(error)")
		}
	}


	public static func tracker(configuration configuration: TrackerConfiguration) -> Tracker {
		return DefaultTracker(configuration: configuration)
	}



	public final class DefaultLogger: Logger {

		public var enabled = true
		public var minimumLevel = LogLevel.Warning


		public func log(@autoclosure message message: () -> String, level: LogLevel) {
			guard enabled && level.rawValue >= minimumLevel.rawValue else {
				return
			}

			NSLog("%@", "[Webtrekk] \(message())")
		}
	}
}
