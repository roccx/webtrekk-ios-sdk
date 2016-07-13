import UIKit
import Webtrekk



class SettingsViewController: UIViewController {

	private let tracker = WebtrekkTracking.sharedTracker.trackerForPage("Settings")

	@IBOutlet weak var optOutSwitch: UISwitch!
	@IBOutlet weak var emailTextField: UITextField!

	private func setUpOptOutSwitch() {
		guard let optOutSwitch = optOutSwitch else {
			return
		}
		optOutSwitch.on = WebtrekkTracking.isOptedOut
	}


	@IBAction func tappedOptOutSwitch(sender: UISwitch) {
		WebtrekkTracking.isOptedOut = sender.on
		tracker.trackAction("OptOut Switch tapped")
	}


	@IBAction func tappedTestCDB(sender: UIButton) {
		guard let emailTextField = emailTextField, text = emailTextField.text where !text.isEmpty else {
			return
		}
		WebtrekkTracking.sharedTracker.crossDeviceProperties.emailAddress = HashableTrackingValue.plain(text)
		tracker.trackAction("Test Cross Device Bridge tapped")
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		setUpOptOutSwitch()
	}
}