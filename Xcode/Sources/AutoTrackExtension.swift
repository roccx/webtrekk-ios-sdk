import UIKit
import Webtrekk

extension UIViewController {
	public override class func initialize() {
		struct Static {
			static var token: dispatch_once_t = 0
		}

		if self !== UIViewController.self {
			return
		}

		dispatch_once(&Static.token) {
			let originalSelector = Selector("viewDidLoad")
			let swizzledSelector = Selector("wtk_viewDidLoad")

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

	// MARK: - Method Swizzling

	func wtk_viewDidLoad() {
		self.wtk_viewDidLoad()
		if let webtrekk = webtrekk {
			webtrekk.track("\(self.dynamicType)")
		}
		else {
			print("currently no webtrekk attached (\(self.dynamicType))")
		}
		
	}
}