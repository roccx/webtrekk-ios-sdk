import UIKit
import Webtrekk


var webtrekk: Webtrekk?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		// the config file is as documented one option to configure the webtrekk instance
		guard let url = NSBundle(forClass: AppDelegate.self).URLForResource("Config", withExtension: "xml") else {
			print("Startup complete! (Config.xml was not found. Webtrekk not instantiated.)")
			return true
		}

		guard let config = TrackerConfiguration(configUrl: url) else {
			print("Startup complete! (Config.xml could not be parsed. Webtrekk not instantiated.)")
			return true
		}
		
		// to demonstrate the remote update behavior, the local update config should be loaded as an example
		var defaultConfig = config
		if let url = NSBundle(forClass: AppDelegate.self).URLForResource("UpdateConfig", withExtension: "xml") {
			defaultConfig.remoteConfigurationUrl = url.absoluteString
		}
		webtrekk = Webtrekk(config: defaultConfig)

		Webtrekk.defaultLogger.minimumLevel = .Info

		print("Startup complete!")
		return true
	}
}
