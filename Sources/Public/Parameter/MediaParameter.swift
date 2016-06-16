import Foundation

public struct MediaParameter {
	public let action:     MediaAction
	public let duration:   Int
	public let name:       String
	public let position:   Int
	public let timeStamp:  NSDate

	public var bandwidth:  Int?
	public var categories: [Int: String]
	public var mute:       Bool?
	public var volume:     Int?

	public init(action: MediaAction,
	            bandwidth: Int? = nil,
	            categories: [Int: String] = [:],
	            duration: Int,
	            mute: Bool? = nil,
	            name: String,
	            position: Int,
	            volume: Int? = nil,
	            timeStamp: NSDate = NSDate()) {
		guard !name.isEmpty else {
			fatalError("name cannot be empty")
		}
		self.action = action
		self.bandwidth = bandwidth
		self.categories = categories
		self.duration = duration
		self.mute = mute
		self.name = name
		self.position = position
		self.volume = volume
		self.timeStamp = timeStamp
	}
}

public enum MediaAction: String {
	case EndOfFile = "eof"
	case Pause     = "pause"
	case Play      = "play"
	case Position  = "pos"
	case Seek      = "seek"
	case Stop      = "stop"
}