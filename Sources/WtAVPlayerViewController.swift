import AVFoundation
import AVKit

public /* final */ class WtAVPlayerViewController: AVPlayerViewController {

	internal var periodicObserver: AnyObject?
	internal var startObserver: AnyObject?
	internal var webtrekk: Webtrekk?

	private let assumeStartedTime: NSValue = NSValue(CMTime: CMTimeMake(1, 100))

	public convenience init(webtrekk: Webtrekk) {
		self.init()
		self.webtrekk = webtrekk
	}

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
}