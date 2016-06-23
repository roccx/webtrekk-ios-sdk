import Foundation


public struct TrackerConfiguration {

	public var automaticallyTrackedPages = [Page]()
	public var automaticallyTracksAdvertisingId = true
	public var automaticallyTracksAppUpdates = true
	public var automaticallyTracksAppVersion = true
	public var automaticallyTracksConnectionType = true
	public var automaticallyTracksEventQueueSize = true
	public var automaticallyTracksInterfaceOrientation = true
	public var configurationUpdateUrl: NSURL? = nil
	public var eventQueueLimit = 1000
	public var maximumSendDelay = NSTimeInterval(5 * 60)
	public var samplingRate = 0
	public var serverUrl: NSURL
	public var sessionTimeoutInterval = NSTimeInterval(30 * 60)
	public var version = 1
	public var webtrekkId: String


	public init(webtrekkId: String, serverUrl: NSURL) {
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	internal func automaticallyTrackedPageForViewControllerTypeName(viewControllerTypeName: String) -> Page? {
		return automaticallyTrackedPages.firstMatching({ $0.matches(viewControllerTypeName: viewControllerTypeName) })
	}


	
	public struct Page {

		public var pageProperties: PageProperties
		public var viewControllerTypeNamePattern: NSRegularExpression


		public init(viewControllerTypeNamePattern: NSRegularExpression, pageProperties: PageProperties) {
			self.pageProperties = pageProperties
			self.viewControllerTypeNamePattern = viewControllerTypeNamePattern
		}


		private func matches(viewControllerTypeName viewControllerTypeName: String) -> Bool {
			return viewControllerTypeNamePattern.rangeOfFirstMatchInString(viewControllerTypeName, options: [], range: NSRange(forString: viewControllerTypeName)).location != NSNotFound
		}
	}
}
