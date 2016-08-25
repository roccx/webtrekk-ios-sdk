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
//  Created by Widget Labs
//

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


	@IBAction
	func tappedTestCDB(sender: UIButton) {
		guard let emailTextField = emailTextField, text = emailTextField.text where !text.isEmpty else {
			return
		}

		WebtrekkTracking.instance().global.crossDeviceProperties.emailAddress = .plain(text)

		autoTracker.trackAction("Test Cross Device Bridge tapped")
	}


	@IBAction
	func tappedOptOutSwitch(sender: UISwitch) {
		WebtrekkTracking.isOptedOut = sender.on
		
		autoTracker.trackAction("OptOut Switch tapped")
	}


	override func viewDidLoad() {
		super.viewDidLoad()

		setUpOptOutSwitch()
	}
}
