import Foundation
import Webtrekk


extension WebtrekkTracking {

	static let sharedTracker: Tracker = {
		WebtrekkTracking.defaultLogger.minimumLevel = .debug

		return try! WebtrekkTracking.createTracker()
	}()
}
