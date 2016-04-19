public struct Plugin: Equatable{
	public var id: String

	public func beforeTrackingSend (parameter: TrackingParameter) -> TrackingParameter {
		return parameter
	}

	public func afterTrackingSend (parameter: TrackingParameter) {
	}
}

public func ==(lhs: Plugin, rhs: Plugin) -> Bool {
	guard lhs.id == rhs.id else {
		return false
	}
	
	return true
}

extension Plugin: Hashable {
	public var hashValue: Int {
		get {
			return id.hash
		}
	}
}