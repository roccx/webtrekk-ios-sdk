import AVFoundation
import AVKit

public /* final */ class WtAvPlayer: AVPlayer {
	internal var periodicObserver: AnyObject?
	internal var startObserver: AnyObject?
	internal var webtrekk: Webtrekk?
	internal var paused: Bool = false

	private let assumeStartedTime: NSValue = NSValue(CMTime: CMTimeMake(1, 100))

	public convenience init(URL url: NSURL, webtrekk: Webtrekk) {
		self.init(URL: url)
		self.webtrekk = webtrekk
		configureAVPlayer()
	}

	public convenience init(playerItem item: AVPlayerItem, webtrekk: Webtrekk) {
		self.init(playerItem: item)
		self.webtrekk = webtrekk
		configureAVPlayer()
	}

	deinit{
		removeObserver(self, forKeyPath: "status")
		removeObserver(self, forKeyPath: "rate")
		if let periodicObserver = periodicObserver {
			removeTimeObserver(periodicObserver)
			self.periodicObserver = nil
		}
		if let startObserver = startObserver {
			removeTimeObserver(startObserver)
			self.startObserver = nil
		}
	}

	func configureAVPlayer() {
		addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
		addObserver(self, forKeyPath: "rate", options: [.New], context: nil)
		startObserver = addBoundaryTimeObserverForTimes([NSValue(CMTime: CMTimeMake(1, 100))], queue: dispatch_get_main_queue()) { [unowned self] in
			if let currentItem = self.currentItem {
				print("\(CMTimeGetSeconds(currentItem.currentTime()))/\(CMTimeGetSeconds(currentItem.duration))")
			}

			print("playback has started")
			self.removeTimeObserver(self.startObserver!)
			self.startObserver = nil
		}
		periodicObserver = addPeriodicTimeObserverForInterval(CMTime(seconds: 5.0, preferredTimescale: 1), queue: dispatch_get_main_queue()) { (time: CMTime) in

			guard self.error == nil else {
				print("error occured: \(self.error)")
				return
			}

			if self.rate != 0{
				if self.paused {
					self.paused = false
					print("\(CMTimeGetSeconds(time)) playing after pause")
				}
				else {
					print("\(CMTimeGetSeconds(time)) still playing")
				}
			} else {
				if self.paused {
					print("\(CMTimeGetSeconds(time)) another paused playing")
				}
				else {
					self.paused = true
					print("\(CMTimeGetSeconds(time)) paused playing")
				}

			}
		}
	}


	override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "status" {
			print("Change at keyPath = \(keyPath) for \(object)")
		}
		if keyPath == "rate" { // needs to register first value as start position, any further is change in play/pause
			print("Change at keyPath = \(keyPath) for \(object): \(self.rate)")
			if let currentItem = self.currentItem {
				if currentItem.currentTime() == currentItem.duration {
					print("media file reached end")
				}
			}
		}
	}
}