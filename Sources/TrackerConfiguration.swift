import Foundation

public struct TrackerConfiguration {
	public var appVersionParameter: String
	public var samplingRate:        Int
	public var sendDelay:           Int
	public var useAdIdentifier:     Bool

	public private(set) var serverUrl:  String
	public private(set) var trackingId: String


	public init(appVersionParameter: String = "", samplingRate: Int = 0, sendDelay: Int = 5 * 60, serverUrl: String, trackingId: String, useAdIdentifier: Bool = false) {
		guard !serverUrl.isEmpty || !trackingId.isEmpty else {
			fatalError("Need serverUrl and trackingId for minimal Configuration")
		}

		guard let _ = NSURL(string: serverUrl) else {
			fatalError("serverUrl needs to be a valid url")
		}

		self.appVersionParameter = appVersionParameter
		self.samplingRate = samplingRate
		self.sendDelay = sendDelay
		self.serverUrl = serverUrl
		self.trackingId = trackingId
		self.useAdIdentifier = useAdIdentifier
	}
}

internal extension TrackerConfiguration {

	internal var baseUrl: NSURL {
		get { return NSURL(string: serverUrl)!.URLByAppendingPathComponent(trackingId).URLByAppendingPathComponent("wt")}
	}
}