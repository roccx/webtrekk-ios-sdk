import AVFoundation
import AVKit
import UIKit
import Webtrekk


class VoucherViewController: UIViewController {

	private let tracker = WebtrekkTracking.sharedTracker.trackerForPage("Voucher Details")


	@IBAction func activateVoucher(sender: AnyObject) {
		tracker.ecommerceProperties.voucherValue = "\(voucherId)"
		tracker.trackAction("Activate Voucher Tapped")
		dismissViewControllerAnimated(true, completion: nil)
	}


	var voucherId = 0 {
		didSet {
			title = "Product \(voucherId)"
		}
	}


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}
