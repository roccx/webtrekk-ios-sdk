import UIKit

#if !os(watchOS)
	import AVFoundation
#endif


public protocol Tracker: class {

	var configuration: TrackerConfiguration { get }
	var crossDeviceProperties: CrossDeviceProperties { get set }
	var everId: String { get }
	var plugins: [TrackerPlugin] { get set }
	var userProperties: UserProperties { get set }


	#if os(watchOS)
	func applicationDidFinishLaunching()
	#else
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?)
	#endif

	func sendPendingEvents()

	func trackAction(event: ActionEvent)

	func trackMedia(event: MediaEvent)

	func trackPageView(event: PageViewEvent)

	@warn_unused_result
	func trackerForMedia(mediaName: String, pageName: String) -> MediaTracker

	#if !os(watchOS)
	func trackerForMedia(mediaName: String, pageName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker
	#endif

	@warn_unused_result
	func trackerForPage(pageName: String) -> PageTracker
}


public extension Tracker {

	public func trackAction(actionName: String, inPage pageName: String) {
		trackAction(ActionEvent(actionProperties: ActionProperties(name: actionName), pageProperties: PageProperties(name: pageName)))
	}


	public func trackPageView(pageName: String) {
		trackPageView(PageViewEvent(pageProperties: PageProperties(name: pageName)))
	}
}
