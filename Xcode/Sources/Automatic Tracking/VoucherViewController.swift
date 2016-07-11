import UIKit
import Webtrekk


class VoucherViewController: UIViewController {

	@IBAction func activateVoucher(sender: AnyObject) {
		autoTracker.ecommerceProperties.voucherValue = "\(voucherId)"
		autoTracker.trackAction("Activate Voucher Tapped")
		dismissViewControllerAnimated(true, completion: nil)
	}

	var voucherId = 0 {
		didSet {
			title = "Voucher \(voucherId)"
		}
	}
}
