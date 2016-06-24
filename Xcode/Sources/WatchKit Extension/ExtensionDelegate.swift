import WatchKit
import Webtrekk


class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        WebtrekkTracking.sharedTracker.applicationDidFinishLaunching()
		WebtrekkTracking.sharedTracker.trackPageView("Home")
    }
}
