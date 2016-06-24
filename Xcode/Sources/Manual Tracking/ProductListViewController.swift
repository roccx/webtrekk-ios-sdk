import UIKit
import Webtrekk


class ProductListViewController: UITableViewController {

	private let tracker = WebtrekkTracking.sharedTracker.trackerForPage("Product Details")


	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openProduct" {
			guard let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) else {
				return
			}
			guard let productViewController = segue.destinationViewController as? ProductViewController else {
				return
			}

			tracker.trackAction("Product tapped")

			productViewController.productId = indexPath.row + 1
		}
	}


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}


extension ProductListViewController { // UITableViewDataSource

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("product", forIndexPath: indexPath)
		cell.textLabel?.text = "Product \(indexPath.row + 1)"

		return cell
	}


	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 100
	}
}
