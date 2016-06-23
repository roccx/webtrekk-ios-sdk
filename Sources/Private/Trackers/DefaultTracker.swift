import AVFoundation
import CoreTelephony
import ReachabilitySwift
import UIKit


internal final class DefaultTracker: Tracker {

	private static let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")

	private lazy var backupManager: BackupManager = BackupManager(fileManager: self.fileManager)
	private lazy var fileManager: FileManager = FileManager(identifier: self.configuration.webtrekkId)
	private lazy var requestManager: RequestManager = RequestManager(backupDelegate: self.backupManager, maximumNumberOfRequests: self.configuration.eventQueueLimit, serverUrl: self.configuration.serverUrl, webtrekkId: self.configuration.webtrekkId)

	private var applicationWillEnterForegroundObserver: NSObjectProtocol?
	private var applicationWillResignActiveObserver: NSObjectProtocol?
	private let defaults: UserDefaults
	private var isFirstEventOfSession = true
	private var isSampling = false

	internal var crossDeviceProperties = CrossDeviceProperties()
	internal var plugins = [TrackerPlugin]()
	internal var userProperties = UserProperties()


	internal init(configuration: TrackerConfiguration) {
		self.defaults = DefaultTracker.sharedDefaults.child(namespace: configuration.webtrekkId)
		self.isFirstEventAfterAppUpdate = defaults.boolForKey(DefaultsKeys.isFirstEventAfterAppUpdate) ?? false
		self.isFirstEventOfApp = defaults.boolForKey(DefaultsKeys.isFirstEventOfApp) ?? true

		var configuration = configuration
		if let configurationData = defaults.dataForKey(DefaultsKeys.configuration) {
			do {
				let savedConfiguration = try XmlTrackerConfigurationParser().parse(xml: configurationData)
				if savedConfiguration.version > configuration.version {
					configuration = savedConfiguration
				}
			}
			catch let error {
				logError("Cannot load saved configuration. Will fall back to initial configuration. Error: \(error)")
			}
		}
		self.configuration = configuration

		setUp()
	}


	deinit {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		if let applicationWillEnterForegroundObserver = applicationWillEnterForegroundObserver {
			notificationCenter.removeObserver(applicationWillEnterForegroundObserver)
		}
		if let applicationWillResignActiveObserver = applicationWillResignActiveObserver {
			notificationCenter.removeObserver(applicationWillResignActiveObserver)
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


	internal func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) {
		NSTimer.scheduledTimerWithTimeInterval(10) {
			self.updateConfiguration()
		}
	}


	private func applicationWillResignActive() {
		defaults.set(key: DefaultsKeys.appHibernationDate, to: NSDate())

		requestManager.shutDown()
		// TODO backup
	}


	private func applicationWillEnterForeground() {
		if let hibernationDate = defaults.dateForKey(DefaultsKeys.appHibernationDate) where -hibernationDate.timeIntervalSinceNow < configuration.sessionTimeoutInterval {
			isFirstEventOfSession = false
		}
		else {
			isFirstEventOfSession = true
		}
	}


	private static let _autotrackingEventHandler = AutotrackingEventHandler()
	internal static var autotrackingEventHandler: protocol<ActionEventHandler, MediaEventHandler, PageViewEventHandler> {
		return _autotrackingEventHandler
	}


	private func autotrackingPagePropertiesNameForViewControllerTypeName(viewControllerTypeName: String) -> PageProperties? {
		return configuration.automaticallyTrackedPages
			.firstMatching({ $0.matches(viewControllerTypeName: viewControllerTypeName) })?
			.pageProperties
	}


	private func checkForAppUpdate() {
		let lastCheckedAppVersion = defaults.stringForKey(DefaultsKeys.appVersion)
		if lastCheckedAppVersion != Environment.appVersion {
			defaults.set(key: DefaultsKeys.appVersion, to: Environment.appVersion)

			if lastCheckedAppVersion != nil {
				isFirstEventAfterAppUpdate = true
			}
		}
	}


	internal private(set) var configuration: TrackerConfiguration {
		didSet {
			updateAutomaticTracking()
			updateSampling()

			requestManager.maximumNumberOfRequests = configuration.eventQueueLimit
		}
	}


	internal func enqueueRequestForEvent(event: TrackerRequest.Event) {
		var requestProperties = TrackerRequest.Properties(
			everId:       DefaultTracker.everId,
			samplingRate: configuration.samplingRate,
			timeZone:     NSTimeZone.defaultTimeZone(),
			timestamp:    NSDate(),
			userAgent:    DefaultTracker.userAgent
		)

		let screenBounds = UIScreen.mainScreen().bounds
		requestProperties.screenSize = (width: Int(screenBounds.width), height: Int(screenBounds.height))

		if isFirstEventAfterAppUpdate {
			requestProperties.isFirstEventAfterAppUpdate = true
		}
		if isFirstEventOfApp {
			requestProperties.isFirstEventOfApp = true
		}
		if isFirstEventOfSession {
			requestProperties.isFirstEventOfSession = true
		}

		if configuration.automaticallyTracksAdvertisingId {
			requestProperties.advertisingId = advertisingIdentifier
		}
		if configuration.automaticallyTracksAppName {
			requestProperties.appVersion = Environment.appVersion
		}
		if configuration.automaticallyTracksConnectionType, let reachability = try? Reachability.reachabilityForInternetConnection() {
			if reachability.isReachableViaWiFi() {
				requestProperties.connectionType = .wifi
			}
			else if reachability.isReachableViaWWAN() {
				if let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology {
					switch  carrierType {
					case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
						requestProperties.connectionType = .cellular_2G
					case CTRadioAccessTechnologyWCDMA,CTRadioAccessTechnologyHSDPA,CTRadioAccessTechnologyHSUPA,CTRadioAccessTechnologyCDMAEVDORev0,CTRadioAccessTechnologyCDMAEVDORevA,CTRadioAccessTechnologyCDMAEVDORevB,CTRadioAccessTechnologyeHRPD:
						requestProperties.connectionType = .cellular_3G
					case CTRadioAccessTechnologyLTE:
						requestProperties.connectionType = .cellular_4G
					default:
						requestProperties.connectionType = .other
					}
				}
				else {
					requestProperties.connectionType = .other
				}
			}
			else if reachability.isReachable() {
				requestProperties.connectionType = .other
			}
			else {
				requestProperties.connectionType = .offline
			}
		}
		if configuration.automaticallyTracksEventQueueSize {
			requestProperties.eventQueueSize = requestManager.requestCount
		}
		if configuration.automaticallyTracksInterfaceOrientation {
			requestProperties.interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
		}

		// FIXME cross-device

		var request = TrackerRequest(
			crossDeviceProperties: crossDeviceProperties,
			event: event,
			properties: requestProperties,
			userProperties: userProperties
		)
		
		logInfo("Request: \(request)")

		for plugin in plugins {
			request = plugin.tracker(self, requestForQueuingRequest: request)
		}

		if shouldEnqueueNewEvents {
			requestManager.enqueueRequest(request, maximumDelay: configuration.maximumSendDelay)
		}

		for plugin in plugins {
			plugin.tracker(self, didQueueRequest: request)
		}

		isFirstEventAfterAppUpdate = false
		isFirstEventOfApp = false
		isFirstEventOfSession = false
	}


	internal static let everId = DefaultTracker.loadEverId()


	private var isFirstEventAfterAppUpdate: Bool {
		didSet {
			guard isFirstEventAfterAppUpdate != oldValue else {
				return
			}

			defaults.set(key: DefaultsKeys.isFirstEventAfterAppUpdate, to: isFirstEventAfterAppUpdate)
		}
	}


	private var isFirstEventOfApp: Bool {
		didSet {
			guard isFirstEventOfApp != oldValue else {
				return
			}

			defaults.set(key: DefaultsKeys.isFirstEventOfApp, to: isFirstEventOfApp)
		}
	}


	internal static var isOptedOut = DefaultTracker.loadIsOptedOut() {
		didSet {
			guard isOptedOut != oldValue else {
				return
			}

			sharedDefaults.set(key: DefaultsKeys.isOptedOut, to: isOptedOut ? true : nil)
		}
	}


	private static func loadEverId() -> String {
		return sharedDefaults.stringForKey(DefaultsKeys.everId) ?? {
			let everId = String(format: "6%010.0f%08lu", arguments: [NSDate().timeIntervalSince1970, arc4random_uniform(99999999) + 1])
			sharedDefaults.set(key: DefaultsKeys.everId, to: everId)
			return everId
			}()
	}


	private static func loadIsOptedOut() -> Bool {
		return sharedDefaults.boolForKey(DefaultsKeys.isOptedOut) ?? false
	}


	internal func sendPendingEvents() {
		requestManager.sendAllRequests()
	}

	
	private func setUp() {
		setUpRequestManager()
		setUpObservers()

		updateAutomaticTracking()
		updateSampling()
	}


	private func setUpObservers() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		applicationWillEnterForegroundObserver = notificationCenter.addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillEnterForeground()
		}
		applicationWillResignActiveObserver = notificationCenter.addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillResignActive()
		}
	}


	private func setUpRequestManager() {
		NSTimer.scheduledTimerWithTimeInterval(5) {
			self.requestManager.sendAllRequests()
		}
	}


	private var shouldEnqueueNewEvents: Bool {
		return isSampling && !DefaultTracker.isOptedOut
	}


	internal func trackAction(actionName: String, inPage pageName: String) {
		trackAction(ActionEvent(actionProperties: ActionProperties(name: actionName), pageProperties: PageProperties(name: pageName)))
	}


	internal func trackAction(event: ActionEvent) {
		handleEvent(event)
	}


	internal func trackMedia(event: MediaEvent) {
		handleEvent(event)
	}


	@warn_unused_result
	internal func trackMedia(mediaName: String) -> MediaTracker {
		return DefaultMediaTracker(handler: self, mediaName: mediaName)
	}


	internal func trackMedia(mediaName: String, byAttachingToPlayer player: AVPlayer) -> MediaTracker {
		let tracker = trackMedia(mediaName)
		AVPlayerTracker.track(player: player, with: tracker)

		return tracker
	}


	@warn_unused_result
	internal func trackPage(pageName: String) -> PageTracker {
		return DefaultPageTracker(handler: self, pageName: pageName)
	}


	internal func trackPageView(pageName: String) {
		trackPageView(PageViewEvent(pageProperties: PageProperties(name: pageName)))
	}


	internal func trackPageView(event: PageViewEvent) {
		handleEvent(event)
	}


	private func updateAutomaticTracking() {
		let handler = DefaultTracker._autotrackingEventHandler

		if configuration.automaticallyTrackedPages.isEmpty {
			if let index = handler.trackers.indexOf({ $0 === self}) {
				handler.trackers.removeAtIndex(index)
			}
		}
		else {
			if !handler.trackers.contains({ $0 === self }) {
				handler.trackers.append(self)
			}

			UIViewController.setUpAutomaticTracking()
		}
	}


	private func updateConfiguration() {
		guard let updateUrl = configuration.configurationUpdateUrl else {
			return
		}

		requestManager.fetch(url: updateUrl) { data, error in
			if let error = error {
				logError("Cannot load configuration from \(updateUrl): \(error)")
				return
			}
			guard let data = data else {
				logError("Cannot load configuration from \(updateUrl): Server returned no data.")
				return
			}

			let configuration: TrackerConfiguration
			do {
				configuration = try XmlTrackerConfigurationParser().parse(xml: data)
			}
			catch let error {
				logError("Cannot parse configuration located at \(updateUrl): \(error)")
				return
			}

			guard configuration.version > self.configuration.version else {
				logInfo("Local configuration is up-to-date with version \(self.configuration.version).")
				return
			}
			guard configuration.webtrekkId == self.configuration.webtrekkId else {
				logError("Cannot apply new configuration located at \(updateUrl): Current webtrekkId (\(self.configuration.webtrekkId)) does not match new webtrekkId (\(configuration.webtrekkId)).")
				return
			}

			logInfo("Updating from configuration version \(self.configuration.version) to version \(configuration.version) located at \(updateUrl).")
			self.defaults.set(key: DefaultsKeys.configuration, to: data)

			self.configuration = configuration
		}
	}


	private func updateSampling() {
		if let isSampling = defaults.boolForKey(DefaultsKeys.isSampling), samplingRate = defaults.intForKey(DefaultsKeys.samplingRate) where samplingRate == configuration.samplingRate {
			self.isSampling = isSampling
		}
		else {
			if configuration.samplingRate > 1 {
				self.isSampling = Int64(arc4random()) % Int64(configuration.samplingRate) == 0
			}
			else {
				self.isSampling = true
			}

			defaults.set(key: DefaultsKeys.isSampling, to: isSampling)
			defaults.set(key: DefaultsKeys.samplingRate, to: configuration.samplingRate)
		}
	}


	private static let userAgent: String = {
		return "Tracking Library \(Webtrekk.version) (\(Environment.operatingSystemName); \(Environment.operatingSystemVersionString); \(Environment.deviceModelString); \(NSLocale.currentLocale().localeIdentifier))"
	}()
}


extension DefaultTracker: ActionEventHandler {

	internal func handleEvent(event: ActionEvent) {
		enqueueRequestForEvent(.action(event))
	}

}


extension DefaultTracker: MediaEventHandler {

	internal func handleEvent(event: MediaEvent) {
		enqueueRequestForEvent(.media(event))
	}

}


extension DefaultTracker: PageViewEventHandler {

	internal func handleEvent(event: PageViewEvent) {
		enqueueRequestForEvent(.pageView(event))
	}
}



private final class AutotrackingEventHandler: ActionEventHandler, MediaEventHandler, PageViewEventHandler {

	private var trackers = [DefaultTracker]()


	private func broadcastEvent<Event: TrackingEvent>(event: Event, handler: (DefaultTracker) -> (Event) -> Void) {
		var event = event

		for tracker in trackers {
			guard let
				viewControllerTypeName = event.pageProperties.viewControllerTypeName,
				pageProperties = tracker.autotrackingPagePropertiesNameForViewControllerTypeName(viewControllerTypeName)
			else {
				continue
			}

			event.pageProperties = event.pageProperties.merged(over: pageProperties)

			handler(tracker)(event)
		}
	}


	private func handleEvent(event: ActionEvent) {
		broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
	}


	private func handleEvent(event: MediaEvent) {
		broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
	}


	private func handleEvent(event: PageViewEvent) {
		broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
	}
}



private struct DefaultsKeys {

	private static let appHibernationDate = "appHibernationDate"
	private static let appVersion = "appVersion"
	private static let configuration = "configuration"
	private static let everId = "everId"
	private static let isFirstEventAfterAppUpdate = "isFirstEventAfterAppUpdate"
	private static let isFirstEventOfApp = "isFirstEventOfApp"
	private static let isSampling = "isSampling"
	private static let isOptedOut = "optedOut"
	private static let samplingRate = "samplingRate"
}
