import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        try! WebtrekkTracking.initTrack()

		return true
	}
}
