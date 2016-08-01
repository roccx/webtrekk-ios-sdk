import UIKit
import Webtrekk
import AdSupport


class ProductListViewController: UITableViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openProduct" {
			guard let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) else {
				return
			}
			guard let productViewController = segue.destinationViewController as? ProductViewController else {
				return
			}
			autoTracker.trackAction("Product tapped")

			productViewController.productId = indexPath.row + 1
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// will be overwriten by global xml value which in turn will be overwritten by screen xml value
		autoTracker.ecommerceProperties.currencyCode = "HKD"

		autoTracker.variables["Key2"] = "value2"
		autoTracker.variables["Key3"] = "value3"
		autoTracker.variables["Key4"] = "value4"
		autoTracker.variables["KeyOverride"] = "valueOverride"
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
