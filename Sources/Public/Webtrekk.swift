import AVFoundation
import CoreTelephony
import ReachabilitySwift
import UIKit


public final class Webtrekk {

	internal typealias ScreenDimension = (width: Int, height: Int)

	public static let version = "4.0"
	public static let pixelVersion = "400"

	public static let defaultLogger = DefaultLogger()

	private lazy var backupManager: BackupManager = BackupManager(fileManager: self.fileManager, logger: self.logger)
	private lazy var fileManager: FileManager = FileManager(logger: self.logger, identifier: self.config.trackingId)
	private lazy var requestManager: RequestManager = RequestManager(logger: self.logger, maximumNumberOfEvents: self.config.maxRequests)

	private var hibernationObserver: NSObjectProtocol?
	private var wakeUpObserver: NSObjectProtocol?

	public var crossDeviceBridge: CrossDeviceBridgeParameter?
	public var plugins = [TrackingPlugin]()
	public var forceNewSession = true


	public init(config: TrackerConfiguration) {
		self.config = config

		setUp()
	}


	deinit {
		if let hibernationObserver = hibernationObserver {
			NSNotificationCenter.defaultCenter().removeObserver(hibernationObserver)
		}
		if let wakeUpObserver = wakeUpObserver {
			NSNotificationCenter.defaultCenter().removeObserver(wakeUpObserver)
		}
	}


	private var advertisingIdentifier: NSUUID? {
		guard
			let identifierManagerClass = unsafeBitCast(NSClassFromString("ASIdentifierManager"), Optional<ASIdentifierManager.Type>.self),
			let manager = identifierManagerClass.sharedManager() where manager.advertisingTrackingEnabled,
			let advertisingIdentifier = manager.advertisingIdentifier
		else {
			return nil
		}

		return advertisingIdentifier
	}


	private func appDidEnterBackground() {
		// store a date to reference how long the app was in background
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setValue(NSDate(), forKey: .ForceNewSession)

		// TODO: shutdown queue
		requestManager.sendAllEvents()
	}


	public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) {
		updateAutomaticTracking()
	}


	private func appUpdate() -> Bool {
		var appVersion: String
		if !config.appVersion.isEmpty {
			appVersion = config.appVersion
		} else if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
			appVersion = version
		}else {
			appVersion = ""
		}

		let userDefaults = NSUserDefaults.standardUserDefaults()
		if let version = userDefaults.stringForKey(UserStoreKey.VersionNumber) {
			if version != appVersion {
				userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
				return true
			}
		} else {
			userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
		}

		return false
	}


	private static let appVersion: String? = {
		return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
	}()


	private static let _autotrackingEventHandler = AutotrackingEventHandler()
	internal static var autotrackingEventHandler: protocol<ActionTrackingEventHandler, MediaTrackingEventHandler, PageTrackingEventHandler> {
		return _autotrackingEventHandler
	}


	private func autotrackingPageNameForClassName(className: String) -> String? {
		for (pattern, screen) in config.autoTrackScreens {
			
		}
	}


	public var config: TrackerConfiguration {
		didSet {
			updateAutomaticTracking()
		}
	}


	private static func deviceModelString() -> String {
		let device = UIDevice.currentDevice()
		if device.isSimulator {
			return "\(operatingSystemName()) Simulator"
		}
		else {
			return device.modelIdentifier
		}
	}

	private func appWillEnterForeground() {
		// TODO: load wating request, check if FNS needs to be set

		let userDefaults = NSUserDefaults.standardUserDefaults()
		if let fns = userDefaults.objectForKey(.ForceNewSession) as? NSDate {
			// TODO: if fns is older then eventOnStartDelay interval then set to next event 
			userDefaults.removeObjectForKey(.ForceNewSession)
		}

	}


	private func defaultUserAgent() -> String {
		return "Tracking Library \(Webtrekk.version) (\(Webtrekk.operatingSystemName()); \(Webtrekk.operatingSystemVersionString()); \(Webtrekk.deviceModelString()); \(NSLocale.currentLocale().localeIdentifier))"
	}


	private static func deviceModelString() -> String {
		let device = UIDevice.currentDevice()
		if device.isSimulator {
			return "\(operatingSystemName()) Simulator"
		}
		else {
			return device.modelIdentifier
		}
	}


	private var everId: String {
		get {

			let userDefaults = NSUserDefaults.standardUserDefaults()
			if let eid = userDefaults.stringForKey(UserStoreKey.Eid) {
				return eid
			}
			let eid = String(format: "6%010.0f%08lu", arguments: [NSDate().timeIntervalSince1970, arc4random_uniform(99999999) + 1])
			userDefaults.setValue(eid, forKey:"eid")
			return eid
		}
		set {
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setValue(newValue, forKey:"eid")
		}
	}


	private func firstStart() -> Bool {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		guard let _ = userDefaults.objectForKey(UserStoreKey.FirstStart) else {
			userDefaults.setBool(true, forKey: UserStoreKey.FirstStart)
			return true
		}
		return false
	}



	public var logger: Logger = Webtrekk.defaultLogger {
		didSet {
			guard logger !== oldValue else {
				return
			}

			fileManager.logger = logger
			requestManager.logger = logger
		}
	}


	private static func operatingSystemName() -> String {
		#if os(iOS)
			return "iOS"
		#elseif os(watchOS)
			return "watchOS"
		#elseif os(tvOS)
			return "tvOS"
		#elseif os(OSX)
			return "macOS"
		#endif
	}


	private static func operatingSystemVersionString() -> String {
		let version = NSProcessInfo().operatingSystemVersion
		if version.patchVersion == 0 {
			return "\(version.majorVersion).\(version.minorVersion)"
		}
		else {
			return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		}
	}


	internal static func screenDimensions() -> ScreenDimension {
		let screenSize: CGRect = UIScreen.mainScreen().bounds
		return (width: Int(screenSize.width), height: Int(screenSize.height))
	}


	public func sendPendingEvents() {
		requestManager.sendAllEvents()
	}

	
	private func setUp() {
		setUpConfig()
		setUpRequestManager()
		setUpOptedOut()
		setUpLifecycleObserver()

		updateAutomaticTracking()
	}


	private func setUpConfig() {
		// check if there is a local dump of the config saved
		if let localConfig = fileManager.restoreConfiguration(config.trackingId) where localConfig.version > config.version {
			self.config = localConfig
		}
		else {
			fileManager.saveConfiguration(config)
		}

		guard config.enableRemoteConfiguration && !config.remoteConfigurationUrl.isEmpty, let url = NSURL(string: config.remoteConfigurationUrl) else {
			return
		}

		guard !config.remoteConfigurationUrl.containsString("file://") else {
			if let xmlString = try? String(contentsOfURL: url), parser = try? XmlConfigParser(xmlString: xmlString), config = parser.trackerConfiguration {
				self.config = config
			}
			return
		}

		requestManager.fetch(url: url) { data, error in
			guard let xmlData = data else {
				self.logger.logInfo("No data could be retrieved from \(self.config.remoteConfigurationUrl).")
				return
			}
			guard let xmlString = String(data: xmlData, encoding: NSUTF8StringEncoding) else {
				self.logger.logInfo("Cannot parse data retreived from \(self.config.remoteConfigurationUrl)")
				return
			}

			let config: TrackerConfiguration!
			do {
				let parser = try XmlConfigParser(xmlString: xmlString)
				config = parser.trackerConfiguration
			} catch {
				self.logger.logInfo("\(WebtrekkError.RemoteParserError)")
				return
			}


			guard config.version > self.config.version else {
				self.logger.logInfo("Remote configuration is not newer then the currently used.")
				return
			}
			self.logger.logInfo("Updating tracker config from version \(self.config.version) to new version \(config.version)")
			self.config = config
			self.fileManager.saveConfiguration(config)
		}
	}


	private func setUpLifecycleObserver() {
		hibernationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			_ in self.appDidEnterBackground()
		}

		wakeUpObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			_ in self.appWillEnterForeground()
		}
	}


	private func setUpOptedOut() {
		config.optedOut =	NSUserDefaults.standardUserDefaults().boolForKey(UserStoreKey.OptedOut)
	}


	private func setUpRequestManager() {
		NSTimer.scheduledTimerWithTimeInterval(5) {
			self.requestManager.sendAllEvents()
		}
	}


	func shouldTrack() -> Bool {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		let userShouldBeSampled: Bool
		if let _ = userDefaults.objectForKey(UserStoreKey.Sampled.rawValue) {
			userShouldBeSampled = userDefaults.boolForKey(UserStoreKey.Sampled)
		}
		else {
			userShouldBeSampled = (config.samplingRate == 0) || (Int64(arc4random()) % Int64(config.samplingRate) == 0)
			userDefaults.setBool(userShouldBeSampled, forKey: UserStoreKey.Sampled.rawValue)
		}
		return userShouldBeSampled && !config.optedOut
	}


	internal func track(eventKind: TrackingEvent.Kind) {
		var eventProperties = TrackingEvent.Properties(
			everId:       everId,
			samplingRate: config.samplingRate,
			timeZone:     NSTimeZone.defaultTimeZone(),
			timestamp:    NSDate(),
			userAgent:    defaultUserAgent()
		)

		eventProperties.isFirstAppStart = firstStart()

		if config.autoTrack {
			if config.autoTrackAdvertiserId {
				eventProperties.advertisingId = advertisingIdentifier
			}
			if config.autoTrackAppVersionName {
				eventProperties.appVersion = Webtrekk.appVersion
			}
			if config.autoTrackConnectionType, let reachability = try? Reachability.reachabilityForInternetConnection() {
				if reachability.isReachableViaWiFi() {
					eventProperties.connectionType = .wifi
				}
				else if reachability.isReachableViaWWAN() {
					if let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology {
						switch  carrierType {
						case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
							eventProperties.connectionType = .mobile(generation: 1)
						case CTRadioAccessTechnologyWCDMA,CTRadioAccessTechnologyHSDPA,CTRadioAccessTechnologyHSUPA,CTRadioAccessTechnologyCDMAEVDORev0,CTRadioAccessTechnologyCDMAEVDORevA,CTRadioAccessTechnologyCDMAEVDORevB,CTRadioAccessTechnologyeHRPD:
							eventProperties.connectionType = .mobile(generation: 2)
						case CTRadioAccessTechnologyLTE:
							eventProperties.connectionType = .mobile(generation: 3)
						default:
							eventProperties.connectionType = .other
						}
					}
					else {
						eventProperties.connectionType = .other
					}

				}
				else if reachability.isReachable() {
					eventProperties.connectionType = .other
				}
				else {
					eventProperties.connectionType = .offline
				}

			}
			if config.autoTrackRequestUrlStoreSize {
				eventProperties.eventQueueSize = requestManager.eventCount
			}
			if config.autoTrackScreenOrientation {
				eventProperties.interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
			}
			if config.autoTrackAppUpdate {
				eventProperties.isAppUpdate = appUpdate()
			}
		}
		// FIXME cross-device
		// FIXME read forceNewSession value and set to event
		
		var event = TrackingEvent(kind: eventKind, properties: eventProperties)

		NSLog("%@", "EVENT: \(event)")

		for plugin in plugins {
			event = plugin.tracker(self, eventForTrackingEvent: event)
		}

		if shouldTrack() {
			requestManager.enqueueEvent(event, maximumDelay: config.sendDelay)
		}

		for plugin in plugins {
			plugin.tracker(self, didTrackEvent: event)
		}
	}


	public func trackAction(action: String, inPage page: String) {
		// TODO
	}


	public func trackMedia(mediaName: String, mediaCategories: Set<Category> = [], player: AVPlayer) {
		AVPlayerTracker.track(
			player: player,
			with:   DefaultMediaTracker(handler: self, mediaName: mediaName, mediaCategories: mediaCategories)
		)
	}


	public func trackViewOfPage(pageName: String) {
		// TODO
	}


	internal static func trackViewOfPage(pageName: String) {
		guard !autoTracker.isEmpty else {
			return
		}

		for tracker in autoTracker {
			tracker.trackViewOfPage(pageName)
		}
	}


	private func track(pageName: String) {
//		track(PageTracking(pageName: pageName))
	}


//	private func track(pageTracking: PageTracking) {
//	/*	var parameter = pageTracking
//		parameter.generalParameter.firstStart = pageTracking.firstStart()
//		enqueue(parameter, config: config)*/
//	}


	private func track(pageName: String, trackingParameter: TrackingParameter) {
		/*
		var parameter = trackingParameter
		parameter.generalParameter.firstStart = trackingParameter.firstStart()
		if parameter.pixelParameter.pageName.isEmpty {
			parameter.pixelParameter.pageName = pageName
		}
		enqueue(parameter, config: config)*/
	}


	private func track(screen: AutoTrackedScreen) {
//		if let pageTracking = screen.pageTracking {
//			track(pageTracking)
//		}
//		else {
//			track(screen.mappingName)
//		}
	}


	public func trackerForMedia(mediaName: String, mediaCategories: Set<Category> = []) -> MediaTracker {
		return DefaultMediaTracker(handler: self, mediaName: mediaName, mediaCategories: mediaCategories)
	}

	
	public func trackerForPage(pageName: String) -> PageTracker {
		return DefaultPageTracker(handler: self, pageName: pageName)
	}


	private func updateAutomaticTracking() {
		let handler = Webtrekk._autotrackingEventHandler

		if config.autoTrack {
			if !handler.trackers.contains({ $0 === self }) {
				handler.trackers.append(self)
			}

			UIViewController.setUpAutomaticTracking()
		}
		else {
			if let index = handler.trackers.indexOf({ $0 === self}) {
				handler.trackers.removeAtIndex(index)
			}
		}
	}



	public final class DefaultLogger: Logger {

		public var enabled = true
		public var minimumLevel = LogLevel.Warning


		public func log(@autoclosure message message: () -> String, level: LogLevel) {
			guard enabled && level.rawValue >= minimumLevel.rawValue else {
				return
			}

			NSLog("%@", "[Webtrekk] \(message())")
		}
	}
}


extension Webtrekk: ActionTrackingEventHandler {

	internal func handleEvent(event: ActionTrackingEvent) {
		track(.action(event))
	}

}


extension Webtrekk: MediaTrackingEventHandler {

	internal func handleEvent(event: MediaTrackingEvent) {
		track(.media(event))
	}

}


extension Webtrekk: PageTrackingEventHandler {

	internal func handleEvent(event: PageTrackingEvent) {
		track(.page(event))
	}
}



private final class AutotrackingEventHandler: ActionTrackingEventHandler, MediaTrackingEventHandler, PageTrackingEventHandler {

	private var trackers = [Webtrekk]()


	private func handleEvent(event: ActionTrackingEvent) {
		var event = event

		for tracker in trackers {
			guard let pageName = tracker.autotrackingPageNameForClassName(event.pageProperties.name) else {
				continue
			}

			event.pageProperties.name = pageName

			tracker.handleEvent(event)
		}
	}


	private func handleEvent(event: MediaTrackingEvent) {
		for tracker in trackers {
			guard let pageName = tracker.autotrackingPageNameForClassName(event.pageProperties.name) else {
				continue
			}

			event.pageProperties.name = pageName

			tracker.handleEvent(event)
		}
	}


	private func handleEvent(event: PageTrackingEvent) {
		for tracker in trackers {
			guard let pageName = tracker.autotrackingPageNameForClassName(event.pageProperties.name) else {
				continue
			}

			event.pageProperties.name = pageName

			tracker.handleEvent(event)
		}
	}
}



public enum WebtrekkError: ErrorType {
	case InitError
	case InitParserError
	case NoTrackerConfiguration
	case RemoteParserError
}
