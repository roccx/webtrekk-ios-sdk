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
			let tabBarController = UITabBarController()
			tabBarController.viewControllers = [MainTestViewController(), FirstTestViewController()]
			tabBarController
			window.rootViewController = tabBarController //UINavigationController(rootViewController: MainTestViewController())
			window.makeKeyAndVisible()
		}

		webtrekk = Webtrekk(config: TrackerConfiguration(sendDelay: 7, serverUrl: "https://usesecure.domain.plz", trackingId: "123456789012345"))

		print("Startup complete!")
		return true
	}
}
