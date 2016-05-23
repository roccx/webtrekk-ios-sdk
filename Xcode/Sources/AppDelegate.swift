import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		if let url = NSBundle(forClass: AppDelegate.self).URLForResource("Config", withExtension: "xml"), let xmlString = try? String(contentsOfURL: url) {
			if let parser = try? XmlConfigParser(xmlString: xmlString) where parser.trackerConfiguration != nil{
				Webtrekk.sharedInstance.config = parser.trackerConfiguration!
				Webtrekk.sharedInstance.enableLoging = true
			}
		}
		print("Startup complete!")
		return true
	}
}
