import UIKit
import Webtrekk



class SettingsViewController: UIViewController {

	@IBOutlet weak var optOutSwitch: UISwitch!
	@IBOutlet weak var emailTextField: UITextField!

	private func setUpOptOutSwitch() {
		guard let optOutSwitch = optOutSwitch else {
			return
		}
		optOutSwitch.on = WebtrekkTracking.isOptedOut
	}


	@IBAction func tappedTestCDB(sender: UIButton) {
		guard let emailTextField = emailTextField, text = emailTextField.text where !text.isEmpty else {
			return
		}
		WebtrekkTracking.sharedTracker.crossDeviceProperties.emailAddress = HashableTrackingValue.plain(text)
		autoTracker.trackAction("Test Cross Device Bridge tapped")
	}


	@IBAction func tappedOptOutSwitch(sender: UISwitch) {
		WebtrekkTracking.isOptedOut = sender.on
		autoTracker.trackAction("OptOut Switch tapped")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpOptOutSwitch()
	}
}