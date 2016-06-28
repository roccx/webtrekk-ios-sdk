import Foundation


public struct TrackerConfiguration {

	public static let allowedMaximumSendDelays: ClosedInterval<NSTimeInterval> = 5 ... .infinity
	public static let allowedRequestQueueLimits: ClosedInterval<Int> = 1 ... .max
	public static let allowedSamplingRates: ClosedInterval<Int> = 0 ... .max
	public static let allowedSessionTimeoutIntervals: ClosedInterval<NSTimeInterval> = 0 ... .infinity
	public static let allowedVersions: ClosedInterval<Int> = 1 ... .max

	public var automaticallyTracksAdvertisingId = true
	public var automaticallyTracksAdvertisingOptOut = true
	public var automaticallyTracksAppUpdates = true
	public var automaticallyTracksAppVersion = true
	public var automaticallyTracksRequestQueueSize = true
	public var configurationUpdateUrl: NSURL? = nil
	public var maximumSendDelay = NSTimeInterval(5 * 60)
	public var requestQueueLimit = 1000
	public var samplingRate = 0
	public var serverUrl: NSURL
	public var sessionTimeoutInterval = NSTimeInterval(30 * 60)
	public var version = 1
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
