import AVKit
import UIKit
import Webtrekk

public final class MediaViewController: UIViewController {
	
	@IBAction func playTapped(sender: UIButton) {
		guard let url = NSBundle(forClass: MediaViewController.self).URLForResource("wt", withExtension: "mp4") else {
			print("file url not possible")
			return
		}
		let avController = AVPlayerViewController()
		guard let webtrekk = webtrekk else {
			return
		}
		avController.player = WtAvPlayer(URL: url, webtrekk: webtrekk)
		do {
			try webtrekk.track("VideoPlayer")
		} catch {
			print("error occured during track \(error)")
		}
		self.presentViewController(avController, animated: true, completion: nil)
	}
}