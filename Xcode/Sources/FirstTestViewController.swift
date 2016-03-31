import AVFoundation
import UIKit
import Webtrekk

internal class FirstTestViewController: UIViewController {

	let button = Button()
	lazy var player: AVPlayer =  {
		guard let url = NSBundle(forClass: FirstTestViewController.self).URLForResource("wt", withExtension: "mp4") else {
			print("config file url not possible")
			return AVPlayer()
		}
		return AVPlayer(URL: url)
	}()
	
	lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)

	internal init() {
		super.init(nibName: nil, bundle: nil)
		tabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 2)
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	private func layoutComponents() {
		let bounds = self.view.bounds
		playerLayer.frame = CGRect(x: 0, y: 25, width: bounds.width, height: 0.5625 * bounds.width)
		button.frame = CGRect(x: 10, y: playerLayer.frame.height + 20 , width: bounds.width - 20, height: 50)
	}


	private func setUp() {
		button.setTitle("Play", forState: .Normal)
		button.setTitleColor(.blackColor(), forState: .Normal)
		button.handle(.TouchUpInside) { (sender:Button) in
			if self.player.status == .ReadyToPlay {
				self.player.play()
			}
		}
		self.view.addSubview(button)
		self.view.layer.addSublayer(playerLayer)
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}


	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutComponents()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		configureAVPlayer()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		player.pause()
		player.removeObserver(self, forKeyPath: "status")
		if let periodicObserver = periodicObserver {
			player.removeTimeObserver(periodicObserver)
		}
	}

	var startObserver: AnyObject?
	var periodicObserver: AnyObject?

	func configureAVPlayer() {
		player.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions(), context: nil)
		player.addObserver(self, forKeyPath: "rate", options: [.New], context: nil)
		startObserver = player.addBoundaryTimeObserverForTimes([NSValue(CMTime: CMTimeMake(1, 100))], queue: dispatch_get_main_queue()) { [unowned self] in
			if let currentItem = self.player.currentItem {
				print("\(CMTimeGetSeconds(currentItem.currentTime()))/\(CMTimeGetSeconds(currentItem.duration))")
			}

			print("playback has started")
			self.player.removeTimeObserver(self.startObserver!)
		}
		periodicObserver = player.addPeriodicTimeObserverForInterval(CMTime(seconds: 5.0, preferredTimescale: 1), queue: dispatch_get_main_queue()) { (time: CMTime) in
			if self.player.rate != 0 && self.player.error == nil {
				print("\(CMTimeGetSeconds(time)) still playing")
			} else {
				print("\(CMTimeGetSeconds(time)) stopped playing")
			}
		}

	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "status" {
			print("Change at keyPath = \(keyPath) for \(object)")
		}
		if keyPath == "rate" { // needs to register first value as start position, any further is change in play/pause
			print("Change at keyPath = \(keyPath) for \(object)")
		}
	}
}

public protocol WebtrekkReference {
	func webtrekkReference() -> Webtrekk?
}

extension AVPlayer: WebtrekkReference {
	public func webtrekkReference() -> Webtrekk? {
		return webtrekk
	}
}
