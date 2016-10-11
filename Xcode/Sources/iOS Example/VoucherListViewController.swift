//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

import UIKit
import Webtrekk


class VoucherListViewController: UITableViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "openVoucher" {
			guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
				return
			}
			guard let voucherViewController = segue.destination as? VoucherViewController else {
				return
			}

			autoTracker.trackAction("Voucher tapped")

			voucherViewController.voucherId = (indexPath as NSIndexPath).row + 1
		}
	}

	@IBAction func cancel(_ sender: AnyObject) {
		dismiss(animated: true, completion: nil)
	}
}


extension VoucherListViewController { // UITableViewDataSource

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "voucher", for: indexPath)
		cell.textLabel?.text = "Voucher \((indexPath as NSIndexPath).row + 1)"

		return cell
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 100
	}
}
