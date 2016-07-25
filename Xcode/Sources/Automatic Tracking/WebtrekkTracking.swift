import Foundation
import UIKit
import Webtrekk


extension WebtrekkTracking {

	static let sharedTracker: Tracker = {
		WebtrekkTracking.defaultLogger.minimumLevel = .debug

		return try! WebtrekkTracking.createTracker()
	}()
}


extension UIViewController {

	var autoTracker: PageTracker {
		return WebtrekkTracking.trackerForAutotrackedViewController(self)
	}
}
