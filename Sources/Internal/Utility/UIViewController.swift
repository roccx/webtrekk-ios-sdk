import UIKit

private var hookIntoLifecycleToken = dispatch_once_t()


internal extension UIViewController {

	private struct AssociatedKeys {

		private static var applicationDidBecomeActiveObserver = UInt8()
		private static var automaticTracker = UInt8()
	}


	@nonobjc
	private static var swizzled = false


	@nonobjc
	internal var applicationDidBecomeActiveObserver: NSObjectProtocol? {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.applicationDidBecomeActiveObserver) as? NSObjectProtocol }
		set { objc_setAssociatedObject(self, &AssociatedKeys.applicationDidBecomeActiveObserver, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}


	@nonobjc
	private func applicationDidBecomeActiveWhileAppeared() {
		automaticTracker.trackPageView()
	}


	@nonobjc
	internal var automaticTracker: PageTracker {
		return objc_getAssociatedObject(self, &AssociatedKeys.automaticTracker) as? PageTracker ?? {
			let tracker = DefaultPageTracker(handler: DefaultTracker.autotrackingEventHandler, viewControllerTypeName: String(reflecting: self.dynamicType))
			objc_setAssociatedObject(self, &AssociatedKeys.automaticTracker, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return tracker
		}()
	}


	@nonobjc
	internal static func setUpAutomaticTracking() {
		guard !swizzled else {
			return
		}

		swizzled = true

		swizzleMethod(ofType: UIViewController.self, fromSelector: #selector(viewDidAppear(_:)), toSelector: #selector(swizzled_viewDidAppear(_:)))
		swizzleMethod(ofType: UIViewController.self, fromSelector: #selector(viewWillDisappear(_:)), toSelector: #selector(swizzled_viewWillDisappear(_:)))
	}


	@objc(Webtrekk_viewDidAppear:)
	private dynamic func swizzled_viewDidAppear(animated: Bool) {
		self.swizzled_viewDidAppear(animated)

		automaticTracker.trackPageView()

		if applicationDidBecomeActiveObserver == nil {
			applicationDidBecomeActiveObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
				self?.applicationDidBecomeActiveWhileAppeared()
			}
		}
	}


	@objc(Webtrekk_viewWillDisappear:)
	private dynamic func swizzled_viewWillDisappear(animated: Bool) {
		self.swizzled_viewWillDisappear(animated)

		if let applicationDidBecomeActiveObserver = applicationDidBecomeActiveObserver {
			NSNotificationCenter.defaultCenter().removeObserver(applicationDidBecomeActiveObserver)
			self.applicationDidBecomeActiveObserver = nil
		}
	}
}
