import UIKit
import Webtrekk

internal var webtrekk: Webtrekk?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		if let window = window {
			window.backgroundColor = UIColor.whiteColor()
			window.rootViewController = UINavigationController(rootViewController: MainTestViewController())
			window.makeKeyAndVisible()
		}

		webtrekk = Webtrekk(config: TrackerConfiguration(serverUrl: "http://usesecure.domain.plz", trackingId: "123456789012345"))

		print("Startup complete!")
		return true
	}
}
