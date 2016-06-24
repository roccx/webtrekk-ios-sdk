import Foundation
import UIKit
import Webtrekk


extension WebtrekkTracking {

	static let sharedTracker: Tracker = {
		WebtrekkTracking.defaultLogger.minimumLevel = .debug

		guard let configurationFile = NSBundle.mainBundle().URLForResource("Webtrekk", withExtension: "xml") else {
			fatalError("Cannot locate Webtrekk.xml")
		}

		do {
			return try WebtrekkTracking.tracker(configurationFile: configurationFile)
		}
		catch let error {
			fatalError("Cannot parse Webtrekk.xml: \(error)")
		}
	}()
}


extension UIViewController {

	var autoTracker: PageTracker {
		return WebtrekkTracking.trackerForAutotrackedViewController(self)
	}
}
