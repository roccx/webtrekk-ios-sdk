import UIKit
import Webtrekk


class VoucherListViewController: UITableViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openVoucher" {
			guard let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) else {
				return
			}
			guard let voucherViewController = segue.destinationViewController as? VoucherViewController else {
				return
			}

			autoTracker.trackAction("Voucher tapped")

			voucherViewController.voucherId = indexPath.row + 1
		}
	}

	@IBAction func cancel(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
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
