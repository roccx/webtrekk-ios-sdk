import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		Webtrekk.appendAutoTracker(Webtrekk.sharedInstance)
		return true
	}
}


extension Webtrekk {

	static let sharedInstance: Webtrekk = {
		Webtrekk.defaultLogger.minimumLevel = .Info

		guard let configurationFile = NSBundle.mainBundle().URLForResource("Webtrekk", withExtension: "xml") else {
			fatalError("Cannot locate Webtrekk.xml")
		}
		guard let configuration = TrackerConfiguration(configUrl: configurationFile) else {
			fatalError("Cannot load Webtrekk.xml")
		}

		return Webtrekk(config: configuration)
	}()
}
