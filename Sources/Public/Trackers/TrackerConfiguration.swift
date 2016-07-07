import Foundation


public struct TrackerConfiguration {

	/** Allowed values for sendDelay */
	public static let allowedMaximumSendDelays: ClosedInterval<NSTimeInterval> = 5 ... .infinity
	/** Allowed values for requestQueueLimit */
	public static let allowedRequestQueueLimits: ClosedInterval<Int> = 1 ... .max
	/** Allowed values for samplingRate */
	public static let allowedSamplingRates: ClosedInterval<Int> = 0 ... .max
	/** Allowed values for sessionTimeoutInterval */
	public static let allowedSessionTimeoutIntervals: ClosedInterval<NSTimeInterval> = 0 ... .infinity
	/** Allowed values for version */
	public static let allowedVersions: ClosedInterval<Int> = 1 ... .max

	public var automaticallyTracksAdvertisingId = true
	public var automaticallyTracksAdvertisingOptOut = true
	public var automaticallyTracksAppUpdates = true
	public var automaticallyTracksAppVersion = true
	public var automaticallyTracksRequestQueueSize = true
	/** Url of the remote configuration. */
	public var configurationUpdateUrl: NSURL? = nil
	/** Delay after which the event request is send to the server. */
	public var maximumSendDelay = NSTimeInterval(5 * 60)
	/** Maxiumum number of request which are stored before sending. */
	public var requestQueueLimit = 1000
	/** The tracker will randomly tracks only every X user. */
	public var samplingRate = 0
	/** Url of the tracking server. */
	public var serverUrl: NSURL
	/** The timout interval indicates after a app went in the background when a new session should be tracked. */
	public var sessionTimeoutInterval = NSTimeInterval(30 * 60)
	/** The version is used to compare the current configuration with a remote configuration and to decide whether there is an update for the configuration available. */
	public var version = 1
	/** */
	public var webtrekkId: String

	#if !os(watchOS)
	public var automaticallyTrackedPages = [Page]()
	public var automaticallyTracksConnectionType = true
	public var automaticallyTracksInterfaceOrientation = true
	#endif


	public init(webtrekkId: String, serverUrl: NSURL) {
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	#if !os(watchOS)
	internal func automaticallyTrackedPageForViewControllerTypeName(viewControllerTypeName: String) -> Page? {
		return automaticallyTrackedPages.firstMatching({ $0.matches(viewControllerTypeName: viewControllerTypeName) })
	}
	#endif



	#if !os(watchOS)
	public struct Page {

		public var customProperties: [String : String]
		public var pageProperties: PageProperties
		public var viewControllerTypeNamePattern: NSRegularExpression


		public init(
			viewControllerTypeNamePattern: NSRegularExpression,
			pageProperties: PageProperties,
			customProperties: [String : String] = [:]
		) {
			self.customProperties = customProperties
			self.pageProperties = pageProperties
			self.viewControllerTypeNamePattern = viewControllerTypeNamePattern
		}


		private func matches(viewControllerTypeName viewControllerTypeName: String) -> Bool {
			return viewControllerTypeNamePattern.rangeOfFirstMatchInString(viewControllerTypeName, options: [], range: NSRange(forString: viewControllerTypeName)).location != NSNotFound
		}
	}
	#endif
}
