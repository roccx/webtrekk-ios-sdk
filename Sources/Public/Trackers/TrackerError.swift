public struct TrackerError: ErrorType {

	public var message: String


	public init(message: String) {
		self.message = message
	}
}
