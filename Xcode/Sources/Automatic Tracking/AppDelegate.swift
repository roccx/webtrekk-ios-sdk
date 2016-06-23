import UIKit
import Webtrekk


@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		Webtrekk.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)

		return true
	}
}


extension Webtrekk {

	static let sharedInstance: Webtrekk = {
		Webtrekk.defaultLogger.minimumLevel = .Info

		guard let configurationFile = NSBundle.mainBundle().URLForResource("Webtrekk", withExtension: "xml") else {
			fatalError("Cannot locate Webtrekk.xml")
		}
		guard let configurationData = NSData(contentsOfURL: configurationFile) else {
			fatalError("Cannot load Webtrekk.xml")
		}

		do {
			return Webtrekk(configuration: try TrackingConfiguration(xml: configurationData))
		}
		catch let error {
			fatalError("Cannot parse Webtrekk.xml: \(error)")
		}
	}()
}
