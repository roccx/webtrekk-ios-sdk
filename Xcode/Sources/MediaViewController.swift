import AVKit
import UIKit
import Webtrekk

public final class MediaViewController: UIViewController {

	// create a tracker for this screen
	private lazy var screenTracker = webtrekk?.trackerForScreen("VideoScreen")

	// the play button was tapped
	@IBAction func playTapped(sender: UIButton) {
		screenTracker?.trackAction("video-button-tapped")
		// check that the resource file is still available
		guard let url = NSBundle(forClass: MediaViewController.self).URLForResource("wt", withExtension: "mp4") else {
			print("file url not possible")
			return
		}
		let avController = AVPlayerViewController()

		// check that we have a valid instance of webtrekk
		guard let webtrekk = webtrekk else {
			return
		}
		// add the webtrekk videoplayer to the av controller
		avController.player = WtAvPlayer(URL: url, webtrekk: webtrekk)
		self.presentViewController(avController, animated: true, completion: nil)
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