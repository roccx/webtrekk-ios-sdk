import UIKit

private var hookIntoLifecycleToken = dispatch_once_t()


internal extension UIViewController {

	private struct AssociatedKeys {

		private static var automaticTracker = UInt8()
		private static var didAppearBefore = UInt8()
		private static var applicationWillEnterForeground = UInt8()
	}


	@nonobjc
	private static var swizzled = false


	private func applicationWillEnterForeground() {
		guard didAppearBefore else {
			return
		}
		automaticTracker.trackPageView()
	}


	internal var applicationWillEnterForegroundObserver: NSObjectProtocol? {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.applicationWillEnterForeground) as? NSObjectProtocol ?? {
			let observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
				self?.applicationWillEnterForeground()
			}
			objc_setAssociatedObject(self, &AssociatedKeys.applicationWillEnterForeground, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return observer
			}()
		}
		set { objc_setAssociatedObject(self, &AssociatedKeys.applicationWillEnterForeground, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}


	@nonobjc
	internal var automaticTracker: PageTracker {
		return objc_getAssociatedObject(self, &AssociatedKeys.automaticTracker) as? PageTracker ?? {
			let tracker = DefaultPageTracker(handler: DefaultTracker.autotrackingEventHandler, viewControllerTypeName: String(reflecting: self.dynamicType))
			objc_setAssociatedObject(self, &AssociatedKeys.automaticTracker, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return tracker
		}()
	}


	internal var didAppearBefore: Bool {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.didAppearBefore) as? Bool ?? false }
		set { objc_setAssociatedObject(self, &AssociatedKeys.didAppearBefore, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}


	@nonobjc
	internal static func setUpAutomaticTracking() {
		guard !swizzled else {
			return
		}

		swizzled = true

		swizzleMethod(ofType: UIViewController.self, fromSelector: #selector(viewDidAppear(_:)), toSelector: #selector(swizzled_viewDidAppear(_:)))
		swizzleMethod(ofType: UIViewController.self, fromSelector: #selector(viewDidDisappear(_:)), toSelector: #selector(swizzled_viewWillDisappear(_:)))
	}


	@objc(Webtrekk_viewDidAppear:)
	private dynamic func swizzled_viewDidAppear(animated: Bool) {
		self.swizzled_viewDidAppear(animated)

		automaticTracker.trackPageView()
		didAppearBefore = true
		guard let _ = applicationWillEnterForegroundObserver else {
			return
		}
	}


	@objc(Webtrekk_viewWillDisappear:)
	private dynamic func swizzled_viewWillDisappear(animated: Bool) {
		self.swizzled_viewWillDisappear(animated)
		guard let observer = applicationWillEnterForegroundObserver else {
			return
		}
		NSNotificationCenter.defaultCenter().removeObserver(observer)
		applicationWillEnterForegroundObserver = nil
		didAppearBefore = false
	}
}
