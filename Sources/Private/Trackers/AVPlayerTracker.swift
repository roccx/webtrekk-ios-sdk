import AVFoundation
import ObjectiveC


internal final class AVPlayerTracker: NSObject {

	private var itemDidPlayToEndTimeObserver: NSObjectProtocol?
	private var parent: MediaTracker
	private var pauseDetectionTimer: NSTimer?
	private var playbackState = PlaybackState.stopped
	private weak var player: AVPlayer?
	private var playerTimeObserver: AnyObject?
	private var positionTimer: NSTimer?
	private var seekCompletionTimer: NSTimer?


	private init(player: AVPlayer, parentTracker: MediaTracker) {
		checkIsOnMainThread()

		self.parent = parentTracker
		self.player = player

		super.init()

		setUpObservers(player: player)

		updatePlaybackState()
	}


	deinit {
		if let itemDidPlayToEndTimeObserver = itemDidPlayToEndTimeObserver {
			NSNotificationCenter.defaultCenter().removeObserver(itemDidPlayToEndTimeObserver)
		}

		pauseDetectionTimer?.invalidate()
		positionTimer?.invalidate()

		let lastKnownPlaybackTime = self._lastKnownPlaybackTime
		let parent = self.parent
		let player = self.player
		let playbackState = self.playbackState

		onMainQueue(synchronousIfPossible: true) {
			switch playbackState {
			case .paused, .pausedOrSeeking, .playing, .seeking:
				if let time = player?.currentTime() {
					parent.mediaProperties.position = CMTimeGetSeconds(time)
				}
				else if let lastKnownPlaybackTime = lastKnownPlaybackTime {
					parent.mediaProperties.position = lastKnownPlaybackTime
				}

				parent.trackEvent(.stop)

			case .finished, .stopped:
				break
			}
		}

		if let player = player, playerTimeObserver = playerTimeObserver {
			onMainQueue(synchronousIfPossible: true) {
				player.removeTimeObserver(playerTimeObserver)
			}
		}
	}


	private var _lastKnownPlaybackTime: NSTimeInterval?
	private var lastKnownPlaybackTime: NSTimeInterval? {
		checkIsOnMainThread()

		if let time = player?.currentTime() {
			_lastKnownPlaybackTime = CMTimeGetSeconds(time)
		}

		return _lastKnownPlaybackTime
	}


	private func onPlayerDeinit(unownedPlayer: Unmanaged<AVPlayer>) {
		onMainQueue(synchronousIfPossible: true) {
			if let playerTimeObserver = self.playerTimeObserver {
				self.playerTimeObserver = nil

				unownedPlayer.takeUnretainedValue().removeTimeObserver(playerTimeObserver)
			}

			self.player = nil
			self.updatePlaybackState()
		}
	}


	private func setUpObservers(player player: AVPlayer) {
		checkIsOnMainThread()

		let mainQueue = NSOperationQueue.mainQueue()
		let notificationCenter = NSNotificationCenter.defaultCenter()

		itemDidPlayToEndTimeObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { [weak self] notification in
			guard let `self` = self, player = self.player where notification.object === player.currentItem else {
				return
			}

			self.updateToPlaybackState(.finished)
		}

		playerTimeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(60, 1), queue: nil) { [weak self] currentTime in
			guard let `self` = self, player = self.player else {
				return
			}

			switch self.playbackState {
			case .finished, .paused, .pausedOrSeeking, .seeking, .stopped:
				if !player.isPlaying {
					self.updateToPlaybackState(.seeking)

					self.seekCompletionTimer?.invalidate()
					self.seekCompletionTimer = NSTimer.scheduledTimerWithTimeInterval(1) { [weak self] in
						guard let `self` = self else {
							return
						}

						self.seekCompletionTimer = nil

						guard self.playbackState == .seeking, let player = self.player else {
							return
						}

						self.updateToPlaybackState(player.isPlaying ? .playing : .paused)
					}
				}

			case .playing:
				break
			}

			self.updatePlaybackState()
		}
	}


	internal static func track(player player: AVPlayer, with tracker: MediaTracker) {
		checkIsOnMainThread()

		player.trackers.add(AVPlayerTracker(player: player, parentTracker: tracker))
	}


	private func updateMediaProperties() {
		checkIsOnMainThread()

		guard let player = player, item = player.currentItem else {
			return
		}

		if let bandwidth = item.accessLog()?.events.last?.indicatedBitrate where bandwidth >= 1 {
			parent.mediaProperties.bandwidth = bandwidth
		}

		if item.duration != kCMTimeIndefinite {
			parent.mediaProperties.duration = CMTimeGetSeconds(item.duration)
		}

		if let lastKnownPlaybackTime = lastKnownPlaybackTime {
			parent.mediaProperties.position = lastKnownPlaybackTime
		}

		let volume = AVAudioSession.sharedInstance().outputVolume * player.volume
		parent.mediaProperties.soundIsMuted = abs(volume) < 0.000001
		parent.mediaProperties.soundVolume = Double(volume)
	}


	private func updatePlaybackState() {
		checkIsOnMainThread()

		let playerIsPlaying = player?.isPlaying ?? false

		switch playbackState {
		case .finished, .paused, .pausedOrSeeking, .seeking, .stopped:
			if playerIsPlaying {
				updateToPlaybackState(.playing)
			}

		case .playing:
			if !playerIsPlaying {
				updateToPlaybackState(.pausedOrSeeking)
			}
		}
	}


	private func updatePositionTimer() {
		checkIsOnMainThread()

		if playbackState == .playing {
			if positionTimer == nil {
				positionTimer = NSTimer.scheduledTimerWithTimeInterval(30, repeats: true) {
					guard self.playbackState == .playing else {
						return
					}

					self.updateMediaProperties()
					self.parent.trackEvent(.position)
				}
			}
		}
		else {
			if let timer = positionTimer {
				timer.invalidate()
				positionTimer = nil
			}
		}
	}


	private func updateToPlaybackState(playbackState: PlaybackState) {
		checkIsOnMainThread()

		guard playbackState != self.playbackState else {
			return
		}

		self.playbackState = playbackState

		pauseDetectionTimer?.invalidate()
		pauseDetectionTimer = nil

		seekCompletionTimer?.invalidate()
		seekCompletionTimer = nil

		if playbackState == .pausedOrSeeking {
			pauseDetectionTimer = NSTimer.scheduledTimerWithTimeInterval(0.5) { [weak self] in
				guard let `self` = self else {
					return
				}

				self.pauseDetectionTimer = nil

				guard self.playbackState == .pausedOrSeeking else {
					return
				}

				self.updateToPlaybackState(.paused)
			}
		}

		updateMediaProperties()

		switch playbackState {
		case .finished: parent.trackEvent(.finish)
		case .paused:   parent.trackEvent(.pause)
		case .playing:  parent.trackEvent(.play)
		case .seeking:  parent.trackEvent(.seek)
		case .stopped:  parent.trackEvent(.stop)
		case .pausedOrSeeking: break
		}

		updatePositionTimer()
	}



	private enum PlaybackState {

		case finished
		case paused
		case pausedOrSeeking
		case playing
		case seeking
		case stopped
	}
}



extension AVPlayer {

	private struct AssociatedKeys {

		private static var trackers = UInt8()
	}



	private var isPlaying: Bool {
		checkIsOnMainThread()

		return abs(rate) >= 0.000001
	}


	private var trackers: Trackers {
		checkIsOnMainThread()

		return objc_getAssociatedObject(self, &AssociatedKeys.trackers) as? Trackers ?? {
			let trackers = Trackers(player: self)
			objc_setAssociatedObject(self, &AssociatedKeys.trackers, trackers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return trackers
		}()
	}



	private final class Trackers {

		private var trackers = [AVPlayerTracker]()
		private let player: Unmanaged<AVPlayer>


		private init(player: AVPlayer) {
			self.player = Unmanaged.passUnretained(player)
		}


		deinit {
			for tracker in trackers {
				tracker.onPlayerDeinit(player)
			}
		}


		private func add(tracker: AVPlayerTracker) {
			trackers.append(tracker)
		}
	}
}
