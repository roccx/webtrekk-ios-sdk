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
//  Created by arsen.vartbaronov on 01/11/16.
//

import UIKit
import Webtrekk

class RecommendationTableViewController: UITableViewController, RecommendationCallback {
    
    var products: [RecommendationProduct]?
    var requestFinished = false
    var lastResult: RecommendationQueryResult?
    var recommendationName = "complexReco"
    var productId: String? = "085cc2g007"

    
    /** returns list of RecommendationProducts and query result from server and connection error in case of connection error*/
    public func onReceiveRecommendations(products: [RecommendationProduct]?, result: RecommendationQueryResult, error: Error?) {
        
        self.lastResult = result
        self.requestFinished = true
        guard result == .ok else {
            WebtrekkTracking.defaultLogger.logDebug("error getting products. Result: \(result), error: \(error?.localizedDescription ?? "nil")")
            return
        }
        
        guard let productsResult = products else {
            WebtrekkTracking.defaultLogger.logDebug("error getting products, with OK result")
            return
        }
        
        self.products = productsResult
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wt = WebtrekkTracking.instance()
        
        guard let recommendation = wt.getRecommendations() else {
            print("getting recommendation error")
            return
        }
        
        guard let _ = recommendation.queryRecommendation(callback: self, name: self.recommendationName)?.setProductID(id: self.productId).call() else {
            print("calling recommendation error")
            return
        }
        
        //tableView.estimatedRowHeight = 150
        //tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.products?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "RecoItemTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecoItemTableViewCell

        guard let products = self.products else {
            print("no products yet")
            return cell
        }
        
        guard indexPath.row < products.count else {
            print("no product for row \(indexPath.row)")
            return cell
        }
        
        let product = products[indexPath.row]
        cell.id.text = product.id
        cell.title.text = product.title
        
        guard let cellTable = cell.viewWithTag(1) else {
            print("can't find table in view")
            return cell
        }
        
        var prevView: UIView? = nil
    
        for productItem in product.values {
            let textItem = UILabel()
            textItem.text = "id:\(productItem.key) type:\(productItem.value.type) value:\(product[productItem.key]!.value)"
            textItem.translatesAutoresizingMaskIntoConstraints = false
            textItem.numberOfLines = 0
            textItem.font = UIFont.systemFont(ofSize: 4.0)
            //textItem.adjustsFontSizeToFitWidth = true
            cellTable.addSubview(textItem)
            if prevView == nil {
                cellTable.addConstraint(NSLayoutConstraint(item: textItem, attribute: .top, relatedBy: .equal, toItem: cellTable, attribute: .top, multiplier: 1.0, constant: 0.0))
            } else {
                cellTable.addConstraint(NSLayoutConstraint(item: textItem, attribute: .top, relatedBy: .equal, toItem: prevView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            }
            cellTable.addConstraint(NSLayoutConstraint(item: textItem, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 6.0))
            cellTable.addConstraint(NSLayoutConstraint(item: textItem, attribute: .width, relatedBy: .equal, toItem: cellTable, attribute: .width, multiplier: 1.0, constant: 0))
            cellTable.addConstraint(NSLayoutConstraint(item: textItem, attribute: .leading, relatedBy: .equal, toItem: cellTable, attribute: .leading, multiplier: 1.0, constant: 0))

            prevView = textItem
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
