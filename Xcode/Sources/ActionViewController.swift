import UIKit

public final class ActionViewController: UIViewController {

	// create a tracker for this screen
	private lazy var screenTracker = webtrekk?.trackerForScreen("ActionScreen")

	@IBAction func buttonTapped(sender: UIButton) {
	}


	// to track the screen attach to the appear and disappear calls of the controller

	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		screenTracker?.didShow()
	}

	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		screenTracker?.willHide()
	}
}