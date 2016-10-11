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
import AdSupport


class ProductListViewController: UITableViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "openProduct" {
			guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
				return
			}
			guard let productViewController = segue.destination as? ProductViewController else {
				return
			}

			autoTracker.trackAction("Product tapped")

			productViewController.productId = (indexPath as NSIndexPath).row + 1
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

		// example for products which are displayed on this screen
		autoTracker.ecommerceProperties.products = [EcommerceProperties.Product(name: "productName1", categories: [1: "productCat11", 2: "productCat12"], price:"100", quantity: 1),		 EcommerceProperties.Product(name: "productName2",categories: [2: "productCat21", 3: "productCat22"], price:"200", quantity: 2)]
	}
}


extension ProductListViewController { // UITableViewDataSource

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath)
		cell.textLabel?.text = "Product \((indexPath as NSIndexPath).row + 1)"

		return cell
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 100
	}
}
