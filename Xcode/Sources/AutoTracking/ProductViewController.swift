import AVFoundation
import AVKit
import UIKit
import Webtrekk


class ProductViewController: UIViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openVideo" {
			guard let playerViewController = segue.destinationViewController as? AVPlayerViewController else {
				return
			}
			guard let videoUrl = NSBundle.mainBundle().URLForResource("Video", withExtension: "mp4") else {
				return
			}

			Webtrekk.sharedInstance.trackAction("Play Video tapped", inPage: "Product Details")

			let player = AVPlayer(URL: videoUrl)
			// TODO how to track page?
			Webtrekk.sharedInstance.trackMedia("product-video-\(productId)", player: player)

			playerViewController.player = player

			player.play()
		}
	}


	var productId = 0 {
		didSet {
			title = "Product \(productId)"
		}
	}
}
