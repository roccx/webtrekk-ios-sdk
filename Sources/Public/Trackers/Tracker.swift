import AVFoundation
import UIKit


public protocol Tracker: class {

	static var isOptedOut: Bool { get set }

	var configuration: TrackerConfiguration { get }
	var crossDeviceProperties: CrossDeviceProperties { get set }
	var everId: String { get }
	var plugins: [TrackerPlugin] { get set }
	var userProperties: UserProperties { get set }


	func application (application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?)

	func sendPendingEvents ()

	func trackAction (event: ActionEvent)

	func trackMedia (event: MediaEvent)

	@warn_unused_result
	func trackMedia (mediaName: String, pageName: String) -> MediaTracker

	func trackMedia (mediaName: String, pageName: String, byAttachingToPlayer player: AVPlayer) -> MediaTracker

	@warn_unused_result
	func trackPage (pageName: String) -> PageTracker

	func trackPageView (event: PageViewEvent)
}


public extension Tracker {

	public func trackAction (actionName: String, inPage pageName: String) {
		trackAction(ActionEvent(actionProperties: ActionProperties(name: actionName), pageProperties: PageProperties(name: pageName)))
	}


	public func trackPageView (pageName: String) {
		trackPageView(PageViewEvent(pageProperties: PageProperties(name: pageName)))
	}
}
