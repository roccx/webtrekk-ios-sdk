import AVFoundation
import CoreTelephony
import ReachabilitySwift
import UIKit


internal final class DefaultTracker: Tracker {

	private static var instances = [ObjectIdentifier: WeakReference<DefaultTracker>]()
	private static let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")

	private let application = UIApplication.sharedApplication()
	private var applicationDidBecomeActiveObserver: NSObjectProtocol?
	private var applicationWillEnterForegroundObserver: NSObjectProtocol?
	private var applicationWillResignActiveObserver: NSObjectProtocol?
	private var backgroundTaskIdentifier = UIBackgroundTaskInvalid
	private let defaults: UserDefaults
	private var isFirstEventOfSession = true
	private var isSampling = false
	private let requestManager: RequestManager
	private var requestManagerStartTimer: NSTimer?
	private let requestQueueBackupFile: NSURL?
	private var requestQueueLoaded = false
	private let requestUrlBuilder: RequestUrlBuilder

	internal var crossDeviceProperties = CrossDeviceProperties()
	internal var plugins = [TrackerPlugin]()
	internal var userProperties = UserProperties()


	internal init(configuration: TrackerConfiguration) {
		var defaults = DefaultTracker.sharedDefaults.child(namespace: configuration.webtrekkId)

		var configuration = configuration
		if let configurationData = defaults.dataForKey(DefaultsKeys.configuration) {
			do {
				let savedConfiguration = try XmlTrackerConfigurationParser().parse(xml: configurationData)
				if savedConfiguration.version > configuration.version {
					logDebug("Using saved configuration (version \(savedConfiguration.version).")
					configuration = savedConfiguration
				}
			}
			catch let error {
				logError("Cannot load saved configuration. Will fall back to initial configuration. Error: \(error)")
			}
		}

		let validatedConfiguration = DefaultTracker.validatedConfiguration(configuration)

		if validatedConfiguration.webtrekkId != configuration.webtrekkId {
			defaults = DefaultTracker.sharedDefaults.child(namespace: validatedConfiguration.webtrekkId)
		}

		configuration = validatedConfiguration

		self.configuration = configuration
		self.defaults = defaults
		self.isFirstEventAfterAppUpdate = defaults.boolForKey(DefaultsKeys.isFirstEventAfterAppUpdate) ?? false
		self.isFirstEventOfApp = defaults.boolForKey(DefaultsKeys.isFirstEventOfApp) ?? true
		self.requestManager = RequestManager(queueLimit: configuration.requestQueueLimit)
		self.requestQueueBackupFile = DefaultTracker.requestQueueBackupFileForWebtrekkId(configuration.webtrekkId)
		self.requestUrlBuilder = RequestUrlBuilder(serverUrl: configuration.serverUrl, webtrekkId: configuration.webtrekkId)

		DefaultTracker.instances[ObjectIdentifier(self)] = WeakReference(self)

		requestManager.delegate = self

		setUp()
	}


	deinit {
		let id = ObjectIdentifier(self)
		onMainQueue {
			DefaultTracker.instances[id] = nil
		}

		if requestManager.started {
			requestManager.stop()
		}

		let notificationCenter = NSNotificationCenter.defaultCenter()
		if let applicationDidBecomeActiveObserver = applicationDidBecomeActiveObserver {
			notificationCenter.removeObserver(applicationDidBecomeActiveObserver)
		}
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
		if requestManagerStartTimer == nil {
			requestManagerStartTimer = NSTimer.scheduledTimerWithTimeInterval(5) {
				self.startRequestManager()
			}
		}

		NSTimer.scheduledTimerWithTimeInterval(15) {
			self.updateConfiguration()
		}
	}


	private func applicationDidBecomeActive() {
		if requestManagerStartTimer == nil {
			requestManagerStartTimer = NSTimer.scheduledTimerWithTimeInterval(5) {
				self.startRequestManager()
			}
		}

		if backgroundTaskIdentifier != UIBackgroundTaskInvalid {
			application.endBackgroundTask(backgroundTaskIdentifier)
			backgroundTaskIdentifier = UIBackgroundTaskInvalid
		}
	}


	private func applicationWillResignActive() {
		defaults.set(key: DefaultsKeys.appHibernationDate, to: NSDate())

		if backgroundTaskIdentifier == UIBackgroundTaskInvalid {
			backgroundTaskIdentifier = application.beginBackgroundTaskWithName("Webtrekk Tracker #\(configuration.webtrekkId)") { [weak self] in
				guard let `self` = self else {
					return
				}

				if self.requestManager.started {
					self.stopRequestManager()
				}

				self.application.endBackgroundTask(self.backgroundTaskIdentifier)
				self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
			}
		}

		if let requestManagerStartTimer = requestManagerStartTimer {
			self.requestManagerStartTimer = nil
			requestManagerStartTimer.fire()
		}

		if backgroundTaskIdentifier != UIBackgroundTaskInvalid {
			saveRequestQueue()
			requestManager.sendAllRequests()
		}
		else {
			stopRequestManager()
		}
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
			self.configuration = DefaultTracker.validatedConfiguration(configuration)

			requestManager.queueLimit = configuration.requestQueueLimit

			requestUrlBuilder.serverUrl = configuration.serverUrl
			requestUrlBuilder.webtrekkId = configuration.webtrekkId

			updateAutomaticTracking()
			updateSampling()
		}
	}


	private func createRequestForEvent(event: TrackerRequest.Event) -> TrackerRequest? {
		guard validateEvent(event) else {
			return nil
		}

		var requestProperties = TrackerRequest.Properties(
			everId:       DefaultTracker.everId,
			samplingRate: configuration.samplingRate,
			timeZone:     NSTimeZone.defaultTimeZone(),
			timestamp:    NSDate(),
			userAgent:    DefaultTracker.userAgent
		)

		let screen = UIScreen.mainScreen()
		requestProperties.screenSize = (width: Int(screen.bounds.width * screen.scale), height: Int(screen.bounds.height * screen.scale))

		if isFirstEventAfterAppUpdate && configuration.automaticallyTracksAppUpdates {
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
		if configuration.automaticallyTracksAppVersion {
			requestProperties.appVersion = Environment.appVersion
		}
		if configuration.automaticallyTracksConnectionType, let reachability = try? Reachability.reachabilityForInternetConnection() {
			if reachability.isReachableViaWiFi() {
				requestProperties.connectionType = .wifi
			}
			else if reachability.isReachableViaWWAN() {
				if let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology {
					switch carrierType {
					case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
						requestProperties.connectionType = .cellular_2G

					case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
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
		if configuration.automaticallyTracksRequestQueueSize {
			requestProperties.requestQueueSize = requestManager.queueSize
		}
		if configuration.automaticallyTracksInterfaceOrientation {
			requestProperties.interfaceOrientation = application.statusBarOrientation
		}

		return TrackerRequest(
			crossDeviceProperties: crossDeviceProperties,
			event: event,
			properties: requestProperties,
			userProperties: userProperties
		)
	}


	internal func enqueueRequestForEvent(event: TrackerRequest.Event) {
		guard var request = createRequestForEvent(eventByApplyingAutomaticPageTracking(to: event)) else {
			return
		}

		for plugin in plugins {
			request = plugin.tracker(self, requestForQueuingRequest: request)
		}

		if shouldEnqueueNewEvents, let requestUrl = requestUrlBuilder.urlForRequest(request) {
			requestManager.enqueueRequest(requestUrl, maximumDelay: configuration.maximumSendDelay)
		}

		for plugin in plugins {
			plugin.tracker(self, didQueueRequest: request)
		}

		isFirstEventAfterAppUpdate = false
		isFirstEventOfApp = false
		isFirstEventOfSession = false
	}


	private func eventByApplyingAutomaticPageTracking(to event: TrackerRequest.Event) -> TrackerRequest.Event {
		guard let
			viewControllerTypeName = event.pageProperties.viewControllerTypeName,
			page = configuration.automaticallyTrackedPageForViewControllerTypeName(viewControllerTypeName)
		else {
			return event
		}

		var event = event
		event.customProperties = event.customProperties.merged(over: page.customProperties)
		event.pageProperties = event.pageProperties.merged(over: page.pageProperties)
		return event
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

			if isOptedOut {
				for trackerReference in instances.values {
					trackerReference.target?.requestManager.clearPendingRequests()
				}
			}
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


	private func loadRequestQueue() {
		guard !requestQueueLoaded else {
			return
		}

		requestQueueLoaded = true

		guard let file = requestQueueBackupFile, filePath = file.path else {
			return
		}

		let fileManager = NSFileManager.defaultManager()
		guard fileManager.fileExistsAtPath(filePath) else {
			return
		}

		guard !DefaultTracker.isOptedOut else {
			do {
				try fileManager.removeItemAtURL(file)
				logDebug("Ignored request queue at '\(file)': User opted out of tracking.")
			}
			catch let error {
				logError("Cannot remove request queue at '\(file)': \(error)")
			}

			return
		}

		let queue: [NSURL]
		do {
			let data = try NSData(contentsOfURL: file, options: [])

			let object: AnyObject?
			if #available(iOS 9.0, *) {
				object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
			}
			else {
				object = NSKeyedUnarchiver.unarchiveObjectWithData(data)
			}

			guard let _queue = object as? [NSURL] else {
				logError("Cannot load request queue from '\(file)': Data has wrong format: \(object)")
				return
			}

			queue = _queue
		}
		catch let error {
			logError("Cannot load request queue from '\(file)': \(error)")
			return
		}

		logDebug("Loaded \(queue.count) queued request(s) from '\(file)'.")
		requestManager.prependRequests(queue)
	}


	private static func requestQueueBackupFileForWebtrekkId(webtrekkId: String) -> NSURL? {
		let searchPathDirectory: NSSearchPathDirectory
		#if os(iOS) || os(OSX) || os(watchOS)
			searchPathDirectory = .ApplicationSupportDirectory
		#elseif os(tvOS)
			searchPathDirectory = .CachesDirectory
		#endif

		let fileManager = NSFileManager.defaultManager()

		var directory: NSURL
		do {
			directory = try fileManager.URLForDirectory(searchPathDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
		}
		catch let error {
			logError("Cannot find directory for storing request queue backup file: \(error)")
			return nil
		}

		directory = directory.URLByAppendingPathComponent("Webtrekk")
		directory = directory.URLByAppendingPathComponent(webtrekkId)

		guard let directoryPath = directory.path else {
			logError("Cannot find directory for storing request queue backup file. Invalid path in '\(directory)'.")
			return nil
		}

		if !fileManager.fileExistsAtPath(directoryPath) {
			do {
				try fileManager.createDirectoryAtURL(directory, withIntermediateDirectories: true, attributes: [NSURLIsExcludedFromBackupKey: true])
			}
			catch let error {
				logError("Cannot create directory at '\(directory)' for storing request queue backup file: \(error)")
				return nil
			}
		}

		return directory.URLByAppendingPathComponent("requestQueue.archive")
	}


	internal func sendPendingEvents() {
		startRequestManager()

		requestManager.sendAllRequests()
	}

	
	private func setUp() {
		setUpObservers()

		updateAutomaticTracking()
		updateSampling()
	}


	private func setUpObservers() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		applicationDidBecomeActiveObserver = notificationCenter.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
			self?.applicationDidBecomeActive()
		}
		applicationWillEnterForegroundObserver = notificationCenter.addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillEnterForeground()
		}
		applicationWillResignActiveObserver = notificationCenter.addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillResignActive()
		}
	}


	private var shouldEnqueueNewEvents: Bool {
		return isSampling && !DefaultTracker.isOptedOut
	}


	private func saveRequestQueue() {
		guard let file = requestQueueBackupFile, filePath = file.path else {
			return
		}

		let queue = requestManager.queue
		guard !queue.isEmpty else {
			let fileManager = NSFileManager.defaultManager()
			if fileManager.fileExistsAtPath(filePath) {
				do {
					try NSFileManager.defaultManager().removeItemAtURL(file)
					logDebug("Deleted request queue at '\(file).")
				}
				catch let error {
					logError("Cannot remove request queue at '\(file)': \(error)")
				}
			}

			return
		}

		let data = NSKeyedArchiver.archivedDataWithRootObject(queue)
		do {
			try data.writeToURL(file, options: .AtomicWrite)
			logDebug("Saved \(queue.count) queued request(s) to '\(file).")
		}
		catch let error {
			logError("Cannot save request queue to '\(file)': \(error)")
		}
	}


	private func startRequestManager() {
		requestManagerStartTimer?.invalidate()
		requestManagerStartTimer = nil

		guard !requestManager.started && application.applicationState == .Active else {
			return
		}

		loadRequestQueue()
		requestManager.start()
	}


	private func stopRequestManager() {
		guard requestManager.started else {
			return
		}

		requestManager.stop()
		saveRequestQueue()
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
		let properties = [
			Environment.operatingSystemName,
			Environment.operatingSystemVersionString,
			Environment.deviceModelString,
			NSLocale.currentLocale().localeIdentifier
		].joinWithSeparator("; ")

		return "Tracking Library \(WebtrekkTracking.version) (\(properties))"
	}()


	private static func validatedConfiguration(configuration: TrackerConfiguration) -> TrackerConfiguration {
		var configuration = configuration
		var problems = [String]()
		var isError = false

		if configuration.webtrekkId.isEmpty {
			configuration.webtrekkId = "ERROR"
			problems.append("webtrekkId must not be empty!! -> changed to 'ERROR'")

			isError = true
		}

		var pageIndex = 0
		configuration.automaticallyTrackedPages = configuration.automaticallyTrackedPages.filter { page in
			defer { pageIndex += 1 }

			guard page.pageProperties.name?.nonEmpty != nil else {
				problems.append("automaticallyTrackedPages[\(pageIndex)] must not be empty")
				return false
			}

			return true
		}

		func checkProperty<Value: Comparable>(name: String, value: Value, allowedValues: ClosedInterval<Value>) -> Value {
			guard !allowedValues.contains(value) else {
				return value
			}

			let newValue = allowedValues.clamp(value)
			problems.append("\(name) (\(value)) must be \(TrackerConfiguration.allowedMaximumSendDelays.conditionText) -> was corrected to \(newValue)")
			return newValue
		}

		configuration.maximumSendDelay       = checkProperty("maximumSendDelay",       value: configuration.maximumSendDelay,       allowedValues: TrackerConfiguration.allowedMaximumSendDelays)
		configuration.requestQueueLimit      = checkProperty("requestQueueLimit",      value: configuration.requestQueueLimit,      allowedValues: TrackerConfiguration.allowedRequestQueueLimits)
		configuration.samplingRate           = checkProperty("samplingRate",           value: configuration.samplingRate,           allowedValues: TrackerConfiguration.allowedSamplingRates)
		configuration.sessionTimeoutInterval = checkProperty("sessionTimeoutInterval", value: configuration.sessionTimeoutInterval, allowedValues: TrackerConfiguration.allowedSessionTimeoutIntervals)
		configuration.version                = checkProperty("version",                value: configuration.version,                allowedValues: TrackerConfiguration.allowedVersions)

		if !problems.isEmpty {
			(isError ? logError : logWarning)("Illegal values in tracker configuration: \(problems.joinWithSeparator(", "))")
		}

		return configuration
	}


	private func validateEvent(event: TrackerRequest.Event) -> Bool {
		switch event {
		case let .action(event):
			guard event.actionProperties.name.nonEmpty != nil else {
				logError("Cannot track action event without action name (actionProperties.name) set: \(event)")
				return false
			}
			guard event.pageProperties.name?.nonEmpty != nil else {
				logError("Cannot track action event without page name (pageProperties.name) set: \(event)")
				return false
			}

			return true

		case let .media(event):
			guard event.mediaProperties.name.nonEmpty != nil else {
				logError("Cannot track media event without media name (mediaProperties.name) set: \(event)")
				return false
			}
			guard event.pageProperties.name?.nonEmpty != nil else {
				logError("Cannot track media event without page name (pageProperties.name) set: \(event)")
				return false
			}

			return true

		case let .pageView(event):
			guard event.pageProperties.name?.nonEmpty != nil else {
				logError("Cannot track page view event without page name (pageProperties.name) set: \(event)")
				return false
			}

			return true
		}
	}
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


extension DefaultTracker: RequestManager.Delegate {

	internal func requestManager(requestManager: RequestManager, didFailToSendRequest request: NSURL, error: RequestManager.Error) {
		requestManagerDidFinishRequest()
	}


	internal func requestManager(requestManager: RequestManager, didSendRequest request: NSURL) {
		requestManagerDidFinishRequest()
	}


	private func requestManagerDidFinishRequest() {
		saveRequestQueue()

		if requestManager.queueSize == 0 {
			if backgroundTaskIdentifier != UIBackgroundTaskInvalid {
				application.endBackgroundTask(backgroundTaskIdentifier)
				backgroundTaskIdentifier = UIBackgroundTaskInvalid
			}

			if application.applicationState != .Active {
				stopRequestManager()
			}
		}
	}
}



private final class AutotrackingEventHandler: ActionEventHandler, MediaEventHandler, PageViewEventHandler {

	private var trackers = [DefaultTracker]()


	private func broadcastEvent<Event: TrackingEvent>(event: Event, handler: (DefaultTracker) -> (Event) -> Void) {
		var event = event

		for tracker in trackers {
			guard let viewControllerTypeName = event.pageProperties.viewControllerTypeName
				where tracker.configuration.automaticallyTrackedPageForViewControllerTypeName(viewControllerTypeName) != nil
			else {
				continue
			}

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
