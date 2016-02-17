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

	private func prepareParameters() {
		// Version name & code
		if let infoDictionary = NSBundle.mainBundle().infoDictionary {
			if let versionString =  infoDictionary["CFBundleShortVersionString"] as? String {
				// set version name here
				print(versionString)
			}
			if let versionCode = infoDictionary["CFBundleVersion"] as? String {
				// set version code here
				print(versionCode)
			}
		}
		// app update
//		if storedVersionCode != versionCode {
//			versionCode changed, app update found, store new versionCode
//		}
	}
	
}