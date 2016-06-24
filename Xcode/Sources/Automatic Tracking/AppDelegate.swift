import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		WebtrekkTracking.sharedTracker.application(application, didFinishLaunchingWithOptions: launchOptions)

		return true
	}
}


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
