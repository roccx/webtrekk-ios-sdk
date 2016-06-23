import UIKit

private var hookIntoLifecycleToken = dispatch_once_t()


internal extension UIViewController {

	private struct AssociatedKeys {

		private static var automaticTracker = UInt8()
	}


	@nonobjc
	private static var swizzled = false


	@nonobjc
	private var automaticTracker: PageTracker {
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
	}


	@objc(Webtrekk_viewDidAppear:)
	private dynamic func swizzled_viewDidAppear(animated: Bool) {
		self.swizzled_viewDidAppear(animated)

		automaticTracker.trackPageView()
	}
}
