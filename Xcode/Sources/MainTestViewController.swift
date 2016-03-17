import UIKit
import Webtrekk

internal class MainTestViewController: UIViewController {

	let button = Button()
	let optOutButton = Button()
	var optedOut = false

	internal init() {
		super.init(nibName: nil, bundle: nil)
		tabBarItem = UITabBarItem(tabBarSystemItem:  .MostRecent, tag: 1)
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	private func layoutButton() {
		let bounds = self.view.bounds
		button.frame = CGRect(x: 10, y: (bounds.height - 25) / 2, width: bounds.width - 20, height: 50)
		optOutButton.frame = CGRect(x: 10, y: button.frame.origin.y + button.bounds.size.height + 10 , width: bounds.width - 20, height: 50)
	}


	private func setUp() {
		button.setTitle("Click", forState: .Normal)
		button.setTitleColor(.blackColor(), forState: .Normal)
		button.handle(.TouchUpInside) { (sender:Button) in
			guard let webtrekk = webtrekk else {
				return
			}
			let actionName = "click"
			var categories = [Int: String]()
			for i in 1...10 {
				categories[i] = "Categorie Parameter \(i)"
			}
			var session = [Int: String]()
			for i in 1...10 {
				session[i] = "Session;Parameter \(i)"
			}
			var products = [ProductParameter]()
			for i in 1...3 {
				var categories = [Int: String]()
				for j in i...7 {
					categories[j] = "Category(\(j))InProduct(\(i))"
				}

				products.append(ProductParameter(categories: categories, currency: i % 2 == 0 ? "" : "EUR", name: "Prodcut\(i)", price: "\(Double(i) * 2.5)", quantity: "\(i)"))
			}
			let actionParameter = ActionParameter(categories: categories, name:actionName, session: session)
			let actionTrackingParameter = ActionTrackingParameter(actionParameter: actionParameter, productParameters: products)
			webtrekk.track(actionTrackingParameter)
//			let vc = PrivateViewController()
//			self.presentViewController(vc, animated: true, completion: nil)
		}
		self.view.addSubview(button)

		optOutButton.setTitle("Toogle OptedOut", forState: .Normal)
		optOutButton.setTitleColor(.blackColor(), forState: .Normal)
		optOutButton.handle(.TouchUpInside) { (sender:Button) in
			guard let webtrekk = webtrekk else {
				return
			}
			self.optedOut = !self.optedOut
			webtrekk.config.optedOut = self.optedOut
		}
		self.view.addSubview(optOutButton)
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}


	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutButton()
	}

}

private class PrivateViewController: UIViewController {

}