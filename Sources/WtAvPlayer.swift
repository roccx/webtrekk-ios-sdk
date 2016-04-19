import AVFoundation
import AVKit

public /* final */ class WtAvPlayer: AVPlayer {
	internal var periodicObserver: AnyObject?
	internal var startObserver: AnyObject?
	internal var webtrekk: Webtrekk?
	internal var paused: Bool = true
	internal var startSeek: Float64 = 0
	internal var endSeek: Float64 = 0

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
		periodicObserver = addPeriodicTimeObserverForInterval(CMTime(seconds: 30.0, preferredTimescale: 1), queue: dispatch_get_main_queue()) { (time: CMTime) in

			guard self.error == nil else {
				print("error occured: \(self.error)")
				return
			}

			if self.rate != 0{
				if self.paused {
					self.paused = false
					print("\(CMTimeGetSeconds(time)) playing after pause")
					if self.startSeek != self.endSeek {
						print("was seeking from \(self.startSeek) to \(self.endSeek)")
						self.startSeek = self.endSeek
					}
				}
				else {
					print("\(CMTimeGetSeconds(time)) still playing")
				}
			} else {
				if self.paused {
					print("\(CMTimeGetSeconds(time)) another paused playing")
					self.endSeek = CMTimeGetSeconds(time)
				}
				else {
					self.paused = true
					print("\(CMTimeGetSeconds(time)) paused playing")
					self.startSeek = CMTimeGetSeconds(time)
					self.endSeek = CMTimeGetSeconds(time)
				}

			}
		}
	}


	override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "rate" { // needs to register first value as start position, any further is change in play/pause
//			if self.rate != 0 {
//				print("started playing")
//			}
//			else if !self.paused {
//				print("stopped playing")
//			}
			if let currentItem = self.currentItem {
				if currentItem.currentTime() == currentItem.duration {
					print("media file reached end")
				}
			}
		}
	}
}