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
		avController.player = WtAvPlayer(URL: url, webtrekk: Webtrekk.sharedInstance)
		do {
			try Webtrekk.sharedInstance.track("VideoPlayer")
		} catch {
			print("error occured during track \(error)")
		}
		self.presentViewController(avController, animated: true, completion: nil)
	}
}