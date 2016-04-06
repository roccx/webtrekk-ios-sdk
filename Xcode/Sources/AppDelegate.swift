import UIKit
import Webtrekk

internal var webtrekk: Webtrekk?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		webtrekk = Webtrekk(config: TrackerConfiguration(sendDelay: 7, serverUrl: "https://q3.webtrekk.net", trackingId: "189053685367929", version: 0))
		webtrekk?.enableLoging = true
		webtrekk?.autoTrackedScreens["MainTestViewController"] = AutoTrackedScreen(className: "MainTestViewController", mappingName: "Home")
		webtrekk?.autoTrackedScreens["FirstTestViewController"] = AutoTrackedScreen(className: "FirstTestViewController", mappingName: "VideoOverview")
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		if let window = window {
			window.backgroundColor = UIColor.whiteColor()
			let tabBarController = UITabBarController()
			tabBarController.viewControllers = [MainTestViewController(), FirstTestViewController()]
			tabBarController
			window.rootViewController = tabBarController
			window.makeKeyAndVisible()
		}

		print("Startup complete!")
		return true
	}
}
