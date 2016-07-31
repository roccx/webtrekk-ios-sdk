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
