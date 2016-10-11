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
//  Created by Widgetlabs
//

import Foundation
import UIKit


public class WebtrekkTracking {

	/** Current version of the sdk */
	public static let version = "4.0"
	

	/** the default implementation of `TrackingLogger` used for the sdk */
	public static let defaultLogger = DefaultTrackingLogger()

	/** Enable, disable or filter log outputs from the sdk by configuring the logger accordingly. A user implementation of `TrackingLogger` can be used too. */
	public static var logger: TrackingLogger = WebtrekkTracking.defaultLogger

	/** Indicates wether the sdk tries to migrated stored data from the previous major version. */
	public static var migratesFromLibraryV3 = true
    
    /** Main track object */
    private static var tracker: Tracker?
    
     /** Get main shared Webtrekk instance. */
    public static func instance() -> Tracker
    {
        guard tracker != nil else
        {
            logger.logError("Tracker isn't initialized. Please call initTrack() first. Application will crash")
            return tracker!
        }
        return tracker!
    }
    
    /** return true if Webtrekk is already initialized. */
    public static func isInitialized()->Bool{
        return tracker != nil
    }

    /** initialize tracking. It should be called before invoking instance() function
     Optional parameter "configurationFile" is used to define location of webtrekk configuration file.
     In case this parameter is nil the default location is in main bundle with name webtrekk_config 
     and xml extension*/
    public static func initTrack(_ configurationFile: URL? = nil) throws
    {
        guard tracker == nil else {
            logger.logWarning("Tracker is arleady initialized. No twice initialization done.")
            return
        }
        
        guard let confFile = configurationFile ?? Bundle.main.url(forResource: "webtrekk_config", withExtension: "xml") else {
            throw TrackerError(message: "Cannot locate webtrekk_config.xml in '\(Bundle.main.bundlePath)'. Either place the file there or use WebtrekkTracking.createTracker(configurationFile:) to specify the file's location.")
        }
        
        checkIsOnMainThread()
        
        tracker = try createTracker(configurationFile: confFile)
    }

	/**
	Creates a `Tracker` with the given configurationFile URL.

	- Parameter configurationFile: The location of the configuration xml.

	- Throws: `TrackError` when the configurationFile could not be located or when the configuration is not valid.
	*/
	private static func createTracker(configurationFile: URL) throws -> Tracker {

		guard let configurationData = try? Data(contentsOf: configurationFile) else {
			throw TrackerError(message: "Cannot load Webtrekk configuration file '\(configurationFile)'")
		}

		do {
			let tracker = DefaultTracker(configuration: try XmlTrackerConfigurationParser().parse(xml: configurationData))
            
            tracker.initTimers()
            
            return tracker
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
	public static func trackerForAutotrackedViewController(_ viewController: UIViewController) -> PageTracker {
		checkIsOnMainThread()

		return viewController.automaticTracker
	}
	#endif
}
