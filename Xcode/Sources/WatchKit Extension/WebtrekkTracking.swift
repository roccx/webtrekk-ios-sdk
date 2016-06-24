import Foundation
import Webtrekk


extension WebtrekkTracking {

	static let sharedTracker: Tracker = {
		WebtrekkTracking.defaultLogger.minimumLevel = .debug

		var configuration = TrackerConfiguration(
			webtrekkId: "289053685367929",
			serverUrl:  NSURL(string: "https://q3.webtrekk.net")!
		)
		configuration.maximumSendDelay = 30

		return WebtrekkTracking.tracker(configuration: configuration)
	}()
}
