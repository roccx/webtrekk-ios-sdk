import Foundation
import UIKit
import Webtrekk


extension UIViewController {

	var autoTracker: PageTracker {
		return WebtrekkTracking.trackerForAutotrackedViewController(self)
	}
}
