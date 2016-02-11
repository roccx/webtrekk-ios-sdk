import Foundation
import UIKit

public class Tracker {

	public var trackerConfiguration: TrackerConfiguration

	private let os = NSProcessInfo().operatingSystemVersion
	private let screenSize = UIScreen.mainScreen().bounds.size
	private let device = UIDevice.currentDevice().modelName
	private let language = NSLocale.currentLocale().localeIdentifier


	public init(trackerConfiguration: TrackerConfiguration) {
		self.trackerConfiguration = trackerConfiguration
	}


	public func track() -> NSURL{
		return track("auto")
	}


	public func track(name: String) -> NSURL{
		return trackerConfiguration.baseUrl
	}
	
}