import Foundation
import UIKit


public enum WebtrekkTracking {

	public static let version = "4.0"

	public static let defaultLogger = DefaultTrackingLogger()
	public static var logger: TrackingLogger = WebtrekkTracking.defaultLogger
	public static var migratesFromLibraryV3 = true


	public static func createTracker() throws -> Tracker {
		checkIsOnMainThread()

		let bundle = NSBundle.mainBundle()
		guard let configurationFile = bundle.URLForResource("Webtrekk", withExtension: "xml") else {
			throw TrackerError(message: "Cannot locate Webtrekk.xml in '\(bundle.bundlePath)'. Either place the file there or use WebtrekkTracking.createTracker(configurationFile:) to specify the file's location.")
		}

		return try createTracker(configurationFile: configurationFile)
	}


	public static func createTracker(configurationFile configurationFile: NSURL) throws -> Tracker {
		checkIsOnMainThread()

		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			throw TrackerError(message: "Cannot load Webtrekk configuration file '\(configurationFile)'")
		}

		do {
			return DefaultTracker(configuration: try XmlTrackerConfigurationParser().parse(xml: configurationData))
		}
		catch let error {
			throw TrackerError(message: "Cannot load Webtrekk configuration file '\(configurationFile)': \(error)")
		}
	}


	public static var isOptedOut: Bool {
		get { return DefaultTracker.isOptedOut }
		set { DefaultTracker.isOptedOut = newValue }
	}


	#if !os(watchOS)
	public static func trackerForAutotrackedViewController(viewController: UIViewController) -> PageTracker {
		checkIsOnMainThread()

		return viewController.automaticTracker
	}
	#endif
}
