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
}
