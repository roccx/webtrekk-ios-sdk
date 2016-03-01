import UIKit

internal class MainTestViewController: UIViewController {

	var rootViewController: UIViewController?
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Initialize your view controller and navigation controller, I assume you have it
		// If not, don't forget to define the variable

		rootViewController = FirstTestViewController()
		navigationController?.viewControllers = [rootViewController!]
		navigationItem.title = "Test Controller"
		print("viewDidLoad")
		if let webtrekk = webtrekk {
			webtrekk.track("\(self)")
		}
	}

}