import UIKit
import Webtrekk


var webtrekk: Webtrekk?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		if let url = NSBundle(forClass: AppDelegate.self).URLForResource("Config", withExtension: "xml"), let xmlString = try? String(contentsOfURL: url) {
			if let parser = try? XmlConfigParser(xmlString: xmlString), let config = parser.trackerConfiguration {

				// to demonstrate the remote update behavior, the local update config should be loaded as an example
				var defaultConfig = config
				if let url = NSBundle(forClass: AppDelegate.self).URLForResource("UpdateConfig", withExtension: "xml") {
					defaultConfig.remoteConfigurationUrl = url.absoluteString
				}
				webtrekk = Webtrekk(config: defaultConfig)
				webtrekk?.enableLoging = true
							}
		}
		print("Startup complete!")
		return true
	}
}
