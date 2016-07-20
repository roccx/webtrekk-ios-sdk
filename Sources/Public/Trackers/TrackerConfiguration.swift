import Foundation


public struct TrackerConfiguration {

	/** Allowed values for sendDelay */
	public static let allowedMaximumSendDelays: ClosedInterval<NSTimeInterval> = 5 ... .infinity

	/** Allowed values for requestQueueLimit */
	public static let allowedRequestQueueLimits: ClosedInterval<Int> = 1 ... .max

	/** Allowed values for resendOnStartEventTime */
	public static let allowedResendOnStartEventTimes: ClosedInterval<NSTimeInterval> = 0 ... .infinity

	/** Allowed values for samplingRate */
	public static let allowedSamplingRates: ClosedInterval<Int> = 0 ... .max

	/** Allowed values for version */
	public static let allowedVersions: ClosedInterval<Int> = 1 ... .max

	/** If enabled automatically tries to attach the Advertising Identifier to each request. */
	public var automaticallyTracksAdvertisingId = true

	/** If enabled automatically tries to attach the Advertising Opt Out state to each request. */
	public var automaticallyTracksAdvertisingOptOut = true

	/** If enabled automatically trackes app updates. */
	public var automaticallyTracksAppUpdates = true

	/** If enabled automatically attaches the app version to each request. */
	public var automaticallyTracksAppVersion = true

	/** If enabled automatically attaches the current request queue size to each request. */
	public var automaticallyTracksRequestQueueSize = true

	/** Url of the remote configuration. */
	public var configurationUpdateUrl: NSURL? = nil

	/** Delay after which the event request is send to the server. */
	public var maximumSendDelay = NSTimeInterval(5 * 60)

	/** Maxiumum number of request which are stored before sending. */
	public var requestQueueLimit = 1000

	/** The timout interval indicating when a new session should be tracked after an app went in the background. */
	public var resendOnStartEventTime = NSTimeInterval(30 * 60)

	/** The tracker will randomly tracks only every X user. */
	public var samplingRate = 0

	/** Url of the tracking server. */
	public var serverUrl: NSURL

	/** The version is used to compare the current configuration with a remote configuration and to decide whether there is an update for the configuration available. */
	public var version = 1

	/** The unique identifier of your webtrekk account. */
	public var webtrekkId: String

	#if !os(watchOS)
	/** Automatically attaches tracker instances to the corresponding view controller if possible. */
	public var automaticallyTrackedPages = [Page]()

	/** If enabled automatically attaches the connection type to each request. */
	public var automaticallyTracksConnectionType = true

	/** If enabled automatically attaches the interface orientation to each request. */
	public var automaticallyTracksInterfaceOrientation = true
	#endif


	/** 
	Configuration for a Tracker

	Enable or disable various automatically tracked features or customize options to fit your requirement.

	- Parameter webtrekkId: The unique identifier of your webtrekk account
	- Parameter serverUrl: Url of the tracking server
	*/
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
	/**
	Representation of an automatically tracked page.
	*/
	public struct Page {

		public var actionProperties: ActionProperties?

		public var advertisementProperties: AdvertisementProperties?

		public var ecommerceProperties: EcommerceProperties?

		public var mediaProperties: MediaProperties?

		/** Page Properties that should be tracked if not overwritten manually. */
		public var pageProperties: PageProperties

		public var sessionDetails: [Int: TrackingValue]?

		public var userProperties: UserProperties?

		/** A Regular Expression to determine a view controller for automatic tracking. */
		public var viewControllerTypeNamePattern: NSRegularExpression


		/**
		- Parameter viewControllerTypeNamePattern: A Regular Expression to determine a view controller for automatic tracking.
		- Parameter pageProperties: Page Properties that should be tracked if not overwritten manually.
		- Parameter customProperties: Custom Properties that should be tracked if not overwritten manually.
		*/
		public init(
			viewControllerTypeNamePattern: NSRegularExpression,
			pageProperties: PageProperties,
			actionProperties: ActionProperties? = nil,
			advertisementProperties: AdvertisementProperties? = nil,
			ecommerceProperties: EcommerceProperties? = nil,
			mediaProperties: MediaProperties? = nil,
			sessionDetails: [Int: TrackingValue]? = nil,
			userProperties: UserProperties? = nil
		) {
			self.actionProperties = actionProperties
			self.advertisementProperties = advertisementProperties
			self.ecommerceProperties = ecommerceProperties
			self.mediaProperties = mediaProperties
			self.pageProperties = pageProperties
			self.sessionDetails = sessionDetails
			self.userProperties = userProperties
			self.viewControllerTypeNamePattern = viewControllerTypeNamePattern
		}


		private func matches(viewControllerTypeName viewControllerTypeName: String) -> Bool {
			return viewControllerTypeNamePattern.rangeOfFirstMatchInString(viewControllerTypeName, options: [], range: NSRange(forString: viewControllerTypeName)).location != NSNotFound
		}
	}
	#endif
}
