import UIKit
import Webtrekk


class VoucherListViewController: UITableViewController {

	private let tracker = WebtrekkTracking.sharedTracker.trackerForPage("Voucher List")


	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openVoucher" {
			guard let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) else {
				return
			}
			guard let voucherViewController = segue.destinationViewController as? VoucherViewController else {
				return
			}

			tracker.trackAction("Voucher tapped")

			voucherViewController.voucherId = indexPath.row + 1
		}
	}


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}


extension VoucherListViewController { // UITableViewDataSource

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("voucher", forIndexPath: indexPath)
		cell.textLabel?.text = "Voucher \(indexPath.row + 1)"

		return cell
	}


	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 100
	}
}
