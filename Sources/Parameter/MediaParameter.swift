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

	public init(action: MediaAction, bandwidth: Int? = nil, categories: [Int: String] = [:], duration: Int, mute: Bool? = nil, name: String, position: Int, volume: Int? = nil, timeStamp: NSDate = NSDate()) {
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

extension MediaParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = "&\(ParameterName.urlParameter(fromName: .MediaName, andValue: name))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaAction, andValue: action.rawValue))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaPosition, andValue: "\(position)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaDuration, andValue: "\(duration)"))"
			urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaTimeStamp, andValue: "\(Int64(timeStamp.timeIntervalSince1970 * 1000))"))"

			if let bandwidth = bandwidth {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaBandwidth, andValue: "\(bandwidth)"))"
			}
			if let mute = mute {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaBandwidth, andValue: mute ? "1" : "0"))"
			}
			if let volume = volume {
				urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaBandwidth, andValue: "\(volume)"))"
			}
			
			if !categories.isEmpty {
				for (index, value) in categories {
					urlParameter += "&\(ParameterName.urlParameter(fromName: .MediaCategories, withIndex: index, andValue: value))"
				}
			}

			return urlParameter
		}
	}
}
