import AVFoundation
import AVKit
import UIKit
import Webtrekk


class ProductViewController: UIViewController {

	private let tracker = Webtrekk.sharedInstance.trackerForPage("Product Details")


	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openVideo" {
			guard let playerViewController = segue.destinationViewController as? AVPlayerViewController else {
				return
			}
			guard let videoUrl = NSBundle.mainBundle().URLForResource("Video", withExtension: "mp4") else {
				return
			}

			tracker.trackAction(name: "Play Video tapped")

			let player = AVPlayer(URL: videoUrl)
			tracker.trackerForMedia(name: "product-video-\(productId)", player: player)

			playerViewController.player = player

			player.play()
		}
	}


	var productId = 0 {
		didSet {
			title = "Product \(productId)"
		}
	}


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}
