import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		Webtrekk.sharedTracker.application(application, didFinishLaunchingWithOptions: launchOptions)

		return true
	}
}


extension Webtrekk {

	static let sharedTracker: Tracker = {
		Webtrekk.defaultLogger.minimumLevel = .Info

		guard let configurationFile = NSBundle.mainBundle().URLForResource("Webtrekk", withExtension: "xml") else {
			fatalError("Cannot locate Webtrekk.xml")
		}

		do {
			return try Webtrekk.tracker(configurationFile: configurationFile)
		}
		catch let error {
			fatalError("Cannot parse Webtrekk.xml: \(error)")
		}
	}()
}
