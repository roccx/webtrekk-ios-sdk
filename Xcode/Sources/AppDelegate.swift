import UIKit
import Webtrekk

internal var webtrekk: Webtrekk?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		webtrekk = Webtrekk(config: TrackerConfiguration(autoTrackScreens: ["MainTestViewController": AutoTrackedScreen(className: "MainTestViewController", mappingName: "Home"), "FirstTestViewController": AutoTrackedScreen(className: "FirstTestViewController", mappingName: "VideoOverview")],enableRemoteConfiguration: true, remoteConfigurationUrl: "https://everald.de/Default.xml", sendDelay: 7, serverUrl: "https://q3.webtrekk.net", trackingId: "289053685367929", version: 2))
		webtrekk?.enableLoging = true
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		if let window = window {
			window.backgroundColor = UIColor.whiteColor()
			let tabBarController = UITabBarController()
			tabBarController.viewControllers = [MainTestViewController(), FirstTestViewController()]
			window.rootViewController = tabBarController
			window.makeKeyAndVisible()
		}

		print("Startup complete!")
		return true
	}
}
