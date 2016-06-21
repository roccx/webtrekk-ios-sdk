import AVFoundation
import AVKit
import UIKit
import Webtrekk

public final class MediaViewController: UIViewController {

	// create a tracker for this screen
	private lazy var screenTracker = webtrekk?.trackerForScreen("VideoScreen")

	// the play button was tapped
	@IBAction
	func playTapped(sender: UIButton) {
		screenTracker?.trackAction(ActionTrackingEvent(actionProperties: ActionProperties(name: "video-button-tapped")))

		// check that we have a valid instance of webtrekk
		guard let webtrekk = webtrekk else {
			return
		}

		// check that the resource file is still available
		guard let mediaUrl = NSBundle(forClass: MediaViewController.self).URLForResource("wt", withExtension: "mp4") else {
			NSLog("file url not possible")
			return
		}

		let player = AVPlayer(URL: mediaUrl)
		webtrekk.trackMedia(player: player, id: "abc")

		let controller = AVPlayerViewController()
		controller.player = player

		presentViewController(controller, animated: true, completion: nil)
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