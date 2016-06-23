import Foundation


public struct MediaProperties {

	public var bandwidth: Double?    // bit/s
	public var categories: Set<Category>?
	public var duration: NSTimeInterval?
	public var name: String
	public var position: NSTimeInterval?
	public var soundIsMuted: Bool?
	public var soundVolume: Double?  // 0 ... 1


	public init(
		name: String,
		bandwidth: Double? = nil,
		categories: Set<Category>? = nil,
		duration: NSTimeInterval? = nil,
		position: NSTimeInterval? = nil,
		soundIsMuted: Bool? = nil,
		soundVolume: Double? = nil
	) {
		self.bandwidth = bandwidth
		self.categories = categories
		self.duration = duration
		self.name = name
		self.position = position
		self.soundIsMuted = soundIsMuted
		self.soundVolume = soundVolume
	}

	
	@warn_unused_result
	internal func merged(with other: MediaProperties) -> MediaProperties {
		return MediaProperties(
			name:         name,
			bandwidth:    bandwidth ?? other.bandwidth,
			categories:   categories ?? other.categories,
			duration:     duration ?? other.duration,
			position:     position ?? other.position,
			soundIsMuted: soundIsMuted ?? other.soundIsMuted,
			soundVolume:  soundVolume ?? other.soundVolume
		)
	}
}
