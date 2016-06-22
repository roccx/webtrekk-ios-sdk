import UIKit


extension UIViewController {

	private struct AssociatedKeys {

		private static var trackers = UInt8()
	}


	public override class func initialize() { // FIXME: another way ??
		struct Static {
			static var token: dispatch_once_t = 0
		}

		if self !== UIViewController.self {
			return
		}

		dispatch_once(&Static.token) {
			let originalSelector = #selector(viewWillAppear)
			let swizzledSelector = #selector(wtk_viewWillAppear)

			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod)
			}
		}
	}


	func wtk_viewWillAppear(animated: Bool) {
		self.wtk_viewWillAppear(animated)
		Webtrekk.trackViewOfPage("page_name")
	}
}