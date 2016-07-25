import Foundation
import UIKit


public enum WebtrekkTracking {

	/** Current version of the sdk */
	public static let version = "4.0"
	

	/** the default implementation of `TrackingLogger` used for the sdk */
	public static let defaultLogger = DefaultTrackingLogger()

	/** Enable, disable or filter log outputs from the sdk by configuring the logger accordingly. A user implementation of `TrackingLogger` can be used too. */
	public static var logger: TrackingLogger = WebtrekkTracking.defaultLogger

	/** Indicates wether the sdk tries to migrated stored data from the previous major version. */
	public static var migratesFromLibraryV3 = true


	/**
	Creates a `Tracker` by assuming that the configuration xml is named `webtrekk_config.xml` and is located within the application main bundle.
	
	- Throws: `TrackError` when the webtrekk_config.xml could not be located or when the configuration is not valid.
	*/
	public static func createTracker() throws -> Tracker {
		checkIsOnMainThread()

		let bundle = NSBundle.mainBundle()
		guard let configurationFile = bundle.URLForResource("webtrekk_config", withExtension: "xml") else {
			throw TrackerError(message: "Cannot locate webtrekk_config.xml in '\(bundle.bundlePath)'. Either place the file there or use WebtrekkTracking.createTracker(configurationFile:) to specify the file's location.")
		}

		return try createTracker(configurationFile: configurationFile)
	}

	/**
	Creates a `Tracker` with the given configurationFile URL.

	- Parameter configurationFile: The location of the configuration xml.

	- Throws: `TrackError` when the configurationFile could not be located or when the configuration is not valid.
	*/
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

	/** Set wether the tracking is disabled or not. */
	public static var isOptedOut: Bool {
		get { return DefaultTracker.isOptedOut }
		set { DefaultTracker.isOptedOut = newValue }
	}


	#if !os(watchOS)
	/** Returns a `PageTracker` for a corresponding `UIViewController` which were configured by the xml. */
	public static func trackerForAutotrackedViewController(viewController: UIViewController) -> PageTracker {
		checkIsOnMainThread()

		return viewController.automaticTracker
	}
	#endif
}
