public protocol Plugin {

	func beforeTrackingSend (parameter: TrackingParameter) -> TrackingParameter
	func afterTrackingSend (parameter: TrackingParameter)
}

public struct DefaultPlugin: Plugin {

	public func beforeTrackingSend (parameter: TrackingParameter) -> TrackingParameter {
		// TODO: log all parameters here
		return parameter
	}

	public func afterTrackingSend (parameter: TrackingParameter) {

	}

}