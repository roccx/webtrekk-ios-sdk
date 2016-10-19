//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

import UIKit

#if os(watchOS)
	import WatchKit
#elseif os(tvOS)
    import AVFoundation
    import ReachabilitySwift
#else
	import AVFoundation
	import CoreTelephony
	import ReachabilitySwift
#endif


internal final class DefaultTracker: Tracker {

	private static var instances = [ObjectIdentifier: WeakReference<DefaultTracker>]()
	private static let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")

	#if !os(watchOS)
	fileprivate let application = UIApplication.shared
	fileprivate var applicationDidBecomeActiveObserver: NSObjectProtocol?
	fileprivate var applicationWillEnterForegroundObserver: NSObjectProtocol?
	fileprivate var applicationWillResignActiveObserver: NSObjectProtocol?
	fileprivate var backgroundTaskIdentifier = UIBackgroundTaskInvalid
	#endif

	private let defaults: UserDefaults
	private var isFirstEventOfSession = true
	private var isSampling = false
	fileprivate let requestManager: RequestManager
	private var requestManagerStartTimer: Timer?
	private let requestQueueBackupFile: URL?
	private var requestQueueLoaded = false
	private let requestUrlBuilder: RequestUrlBuilder
    private let campaign: Campaign
    private let deepLink = DeepLink()
    /**this value override pu parameter if it is setup from code in any other way or configuraion xml*/
    var pageURL: String?

	internal var global = GlobalProperties()
	internal var plugins = [TrackerPlugin]()


	internal init(configuration: TrackerConfiguration) {
		checkIsOnMainThread()

		let sharedDefaults = DefaultTracker.sharedDefaults
		var defaults = sharedDefaults.child(namespace: configuration.webtrekkId)

		var migratedRequestQueue: [URL]?
		if let webtrekkId = configuration.webtrekkId.nonEmpty , !(sharedDefaults.boolForKey(DefaultsKeys.migrationCompleted) ?? false) {
			sharedDefaults.set(key: DefaultsKeys.migrationCompleted, to: true)

			if WebtrekkTracking.migratesFromLibraryV3, let migration = Migration.migrateFromLibraryV3(webtrekkId: webtrekkId) {

				sharedDefaults.set(key: DefaultsKeys.everId, to: migration.everId)

				if let appVersion = migration.appVersion {
					defaults.set(key: DefaultsKeys.appVersion, to: appVersion)
				}
				if !DefaultTracker.isOptedOutWasSetManually, let isOptedOut = migration.isOptedOut {
					sharedDefaults.set(key: DefaultsKeys.isOptedOut, to: isOptedOut ? true : nil)
				}
				if let samplingRate = migration.samplingRate, let isSampling = migration.isSampling {
					defaults.set(key: DefaultsKeys.isSampling, to: isSampling)
					defaults.set(key: DefaultsKeys.samplingRate, to: samplingRate)
				}

				migratedRequestQueue = migration.requestQueue as [URL]?

				logInfo("Migrated from Webtrekk Library v3: \(migration)")
			}
		}

		var configuration = configuration
		if let configurationData = defaults.dataForKey(DefaultsKeys.configuration) {
			do {
				let savedConfiguration = try XmlTrackerConfigurationParser().parse(xml: configurationData)
				if savedConfiguration.version > configuration.version {
					logDebug("Using saved configuration (version \(savedConfiguration.version)).")
					configuration = savedConfiguration
				}
			}
			catch let error {
				logError("Cannot load saved configuration. Will fall back to initial configuration. Error: \(error)")
			}
		}

		let validatedConfiguration = DefaultTracker.validatedConfiguration(configuration)

		if validatedConfiguration.webtrekkId != configuration.webtrekkId {
			defaults = sharedDefaults.child(namespace: validatedConfiguration.webtrekkId)
		}

		configuration = validatedConfiguration

		self.configuration = configuration
		self.defaults = defaults
		self.isFirstEventAfterAppUpdate = defaults.boolForKey(DefaultsKeys.isFirstEventAfterAppUpdate) ?? false
		self.isFirstEventOfApp = defaults.boolForKey(DefaultsKeys.isFirstEventOfApp) ?? true
		self.requestManager = RequestManager(queueLimit: configuration.requestQueueLimit)
		self.requestQueueBackupFile = DefaultTracker.requestQueueBackupFileForWebtrekkId(configuration.webtrekkId)
		self.requestUrlBuilder = RequestUrlBuilder(serverUrl: configuration.serverUrl, webtrekkId: configuration.webtrekkId)

        self.campaign = Campaign(trackID: configuration.webtrekkId)
        
        campaign.processCampaign()
		
        DefaultTracker.instances[ObjectIdentifier(self)] = WeakReference(self)

		requestManager.delegate = self

		if let migratedRequestQueue = migratedRequestQueue , !DefaultTracker.isOptedOut {
			requestManager.prependRequests(migratedRequestQueue)
		}

		setUp()

		checkForDuplicateTrackers()

	}


	deinit {
		let id = ObjectIdentifier(self)
		let requestManager = self.requestManager

		onMainQueue(synchronousIfPossible: true) {
			DefaultTracker.instances[id] = nil

			if requestManager.started {
				requestManager.stop()
			}
		}

		#if !os(watchOS)
			let notificationCenter = NotificationCenter.default
			if let applicationDidBecomeActiveObserver = applicationDidBecomeActiveObserver {
				notificationCenter.removeObserver(applicationDidBecomeActiveObserver)
			}
			if let applicationWillEnterForegroundObserver = applicationWillEnterForegroundObserver {
				notificationCenter.removeObserver(applicationWillEnterForegroundObserver)
			}
			if let applicationWillResignActiveObserver = applicationWillResignActiveObserver {
				notificationCenter.removeObserver(applicationWillResignActiveObserver)
			}
            
		#endif
	}


	#if os(watchOS)
	internal func applicationDidFinishLaunching() {
		checkIsOnMainThread()

		if requestManagerStartTimer == nil {
			requestManagerStartTimer = NSTimer.scheduledTimerWithTimeInterval(configuration.maximumSendDelay) {
				self.startRequestManager()
			}
		}

		NSTimer.scheduledTimerWithTimeInterval(15) {
			self.updateConfiguration()
		}
	}
	#else
	internal func initTimers() {
		checkIsOnMainThread()

		if requestManagerStartTimer == nil {
			requestManagerStartTimer = Timer.scheduledTimerWithTimeInterval(configuration.maximumSendDelay) {
				self.startRequestManager()
			}
		}

		let _ = Timer.scheduledTimerWithTimeInterval(15) {
			self.updateConfiguration()
		}
	}


	private func applicationDidBecomeActive() {
		checkIsOnMainThread()

		if requestManagerStartTimer == nil {
			requestManagerStartTimer = Timer.scheduledTimerWithTimeInterval(configuration.maximumSendDelay) {
				self.startRequestManager()
			}
		}

		if backgroundTaskIdentifier != UIBackgroundTaskInvalid {
			application.endBackgroundTask(backgroundTaskIdentifier)
			backgroundTaskIdentifier = UIBackgroundTaskInvalid
		}
	}


	private func applicationWillResignActive() {
		checkIsOnMainThread()

		defaults.set(key: DefaultsKeys.appHibernationDate, to: Date())

		if backgroundTaskIdentifier == UIBackgroundTaskInvalid {
			backgroundTaskIdentifier = application.beginBackgroundTask(withName: "Webtrekk Tracker #\(configuration.webtrekkId)") { [weak self] in
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
		checkIsOnMainThread()

		if let hibernationDate = defaults.dateForKey(DefaultsKeys.appHibernationDate) , -hibernationDate.timeIntervalSinceNow < configuration.resendOnStartEventTime {
			isFirstEventOfSession = false
		}
		else {
			isFirstEventOfSession = true
		}
	}
	#endif


	#if !os(watchOS)
	private static let _autotrackingEventHandler = AutotrackingEventHandler()
	internal static var autotrackingEventHandler: ActionEventHandler & MediaEventHandler & PageViewEventHandler {
		return _autotrackingEventHandler
	}
	#endif


	private func checkForAppUpdate() {
		checkIsOnMainThread()

		let lastCheckedAppVersion = defaults.stringForKey(DefaultsKeys.appVersion)
		if lastCheckedAppVersion != Environment.appVersion {
			defaults.set(key: DefaultsKeys.appVersion, to: Environment.appVersion)

			if lastCheckedAppVersion != nil {
				isFirstEventAfterAppUpdate = true
			}
		}
	}


	private func checkForDuplicateTrackers() {
		let hasDuplicate = DefaultTracker.instances.values.contains { $0.target?.configuration.webtrekkId == configuration.webtrekkId && $0.target !== self }
		if hasDuplicate {
			logError("Multiple tracker instances for the same Webtrekk ID '\(configuration.webtrekkId)' were created. This is not supported and will corrupt tracking.")
		}
	}


	internal fileprivate(set) var configuration: TrackerConfiguration {
		didSet {
			checkIsOnMainThread()

			self.configuration = DefaultTracker.validatedConfiguration(configuration)

			requestManager.queueLimit = configuration.requestQueueLimit

			requestUrlBuilder.serverUrl = configuration.serverUrl
			requestUrlBuilder.webtrekkId = configuration.webtrekkId

			updateSampling()

			#if !os(watchOS)
				updateAutomaticTracking()
			#endif
		}
	}


	private func createRequestForEvent(_ event: TrackingEvent) -> TrackerRequest? {
		checkIsOnMainThread()

		guard validateEvent(event) else {
			return nil
		}

		var requestProperties = TrackerRequest.Properties(
			everId:       everId,
			samplingRate: configuration.samplingRate,
			timeZone:     TimeZone.current,
			timestamp:    Date(),
			userAgent:    DefaultTracker.userAgent
		)
		requestProperties.locale = Locale.current

		#if os(watchOS)
			let device = WKInterfaceDevice.currentDevice()
			requestProperties.screenSize = (width: Int(device.screenBounds.width * device.screenScale), height: Int(device.screenBounds.height * device.screenScale))
		#else
			let screen = UIScreen.main
			requestProperties.screenSize = (width: Int(screen.bounds.width * screen.scale), height: Int(screen.bounds.height * screen.scale))
		#endif

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
			requestProperties.advertisingId = Environment.advertisingIdentifierManager?.advertisingIdentifier
		}
		if configuration.automaticallyTracksAdvertisingOptOut {
			requestProperties.advertisingTrackingEnabled = Environment.advertisingIdentifierManager?.advertisingTrackingEnabled
		}
		if configuration.automaticallyTracksAppVersion {
			requestProperties.appVersion = Environment.appVersion
		}
		if configuration.automaticallyTracksRequestQueueSize {
			requestProperties.requestQueueSize = requestManager.queue.count
		}

		#if !os(watchOS) && !os(tvOS)
			if configuration.automaticallyTracksConnectionType, let connectionType = retrieveConnectionType(){
				requestProperties.connectionType = connectionType
			}

			if configuration.automaticallyTracksInterfaceOrientation {
				requestProperties.interfaceOrientation = application.statusBarOrientation
			}
		#endif

		return TrackerRequest(
			crossDeviceProperties: global.crossDeviceProperties,
			event: event,
			properties: requestProperties
		)
	}


	internal func enqueueRequestForEvent(_ event: TrackingEvent) {
		checkIsOnMainThread()

        //merge lowest priority global properties over request properties.
        
        var event = globalPropertiesByApplyingEvent(from: event)

		#if !os(watchOS)
			event = eventByApplyingAutomaticPageTracking(to: event)
		#endif

        event = campaignOverride(to :event) ?? event
        
        event = deepLinkOverride(to: event) ?? event
        
        event = pageURLOverride(to: event) ?? event
		
        guard var request = createRequestForEvent(event) else {
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
    
    // override media code in request in case of deeplink
    
    private func deepLinkOverride(to event: TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithAdvertisementProperties,
            let _ = event as? TrackingEventWithEcommerceProperties else{
                return nil
        }
    
        if let mc = deepLink.getAndDeletSavedDeepLinkMediaCode() {
            var returnEvent = event
            
            var eventWithAdvertisementProperties = returnEvent as! TrackingEventWithAdvertisementProperties
            eventWithAdvertisementProperties.advertisementProperties.id = mc
            returnEvent = eventWithAdvertisementProperties
            
            return returnEvent
        }
        
        return nil
    }
    
    // override some parameter in request if campaign is completed
    private func campaignOverride(to event: TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithAdvertisementProperties,
            let _ = event as? TrackingEventWithEcommerceProperties else{
                return nil
        }
        
        if let mc = campaign.getAndDeletSavedMediaCode() {
                var returnEvent = event
                    
                var eventWithAdvertisementProperties = returnEvent as! TrackingEventWithAdvertisementProperties
                eventWithAdvertisementProperties.advertisementProperties.id = mc
                eventWithAdvertisementProperties.advertisementProperties.action = "c"
                returnEvent = eventWithAdvertisementProperties
            
                var eventWithEcommerceProperties = returnEvent as! TrackingEventWithEcommerceProperties
                var detailsToAdd = eventWithEcommerceProperties.ecommerceProperties.details ?? [Int: TrackingValue]()
                detailsToAdd[900] = "1"
                eventWithEcommerceProperties.ecommerceProperties.details = detailsToAdd
                returnEvent = eventWithEcommerceProperties
            
                return returnEvent
            }
        
        return nil
    }
    
    //override PageURLParameter
    private func pageURLOverride(to event:TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithPageProperties else{
                return nil
        }
        
        if let pageURL = self.pageURL {
            
            guard pageURL.isValidURL() else {
                WebtrekkTracking.defaultLogger.logError("Invalid URL \(pageURL) for override pu parameter")
                return nil
            }

            var returnEvent = event
            
            var eventWithPageProperties = returnEvent as! TrackingEventWithPageProperties
            eventWithPageProperties.pageProperties.url = pageURL
            returnEvent = eventWithPageProperties
            
            return returnEvent
        }
        
        return nil
    }
    

	#if !os(watchOS)
	private func eventByApplyingAutomaticPageTracking(to event: TrackingEvent) -> TrackingEvent {
		checkIsOnMainThread()

		guard let
			viewControllerType = event.viewControllerType,
			let pageProperties = configuration.automaticallyTrackedPageForViewControllerType(viewControllerType)
		else {
			return event
		}
        
        if let page = applyKeys(keys: event.variables, properties: pageProperties) as? TrackerConfiguration.Page {
            return mergeProperties(event: event, properties: page, rewriteEvent: true)
        } else {
            WebtrekkTracking.logger.logError("incorect type of return value from apply Keys for page parameters")
            return event
        }
	}
	#endif


	private func globalPropertiesByApplyingEvent(from event: TrackingEvent) -> TrackingEvent {
		checkIsOnMainThread()
        
        var event = event
        
        event.variables = self.global.variables.merged(over: event.variables)
        
        if let globalSettings = applyKeys(keys: event.variables, properties: configuration.globalProperties) as? GlobalProperties {

            let global = globalSettings.merged(over: self.global)

            return mergeProperties(event: event, properties: global, rewriteEvent: false)
        } else {
            WebtrekkTracking.logger.logError("incorect type of return value from apply Keys for global parameters")
            return event
        }
	}
    
    private func mergeProperties(event: TrackingEvent, properties: BaseProperties, rewriteEvent: Bool) -> TrackingEvent {
        
        let mergeTool = PropertyMerger()
        var event = event
        
        if rewriteEvent {
            event.ipAddress = properties.ipAddress ?? event.ipAddress
            event.pageName = properties.pageProperties.name ?? event.pageName
        }else{
            event.ipAddress = event.ipAddress ?? properties.ipAddress
            event.pageName = event.pageName ?? properties.pageProperties.name
        }
        
        guard !(event is ActionEvent) else {
            return event
        }
        
        if var eventWithActionProperties = event as? TrackingEventWithActionProperties {
            eventWithActionProperties.actionProperties = mergeTool.mergeProperties(first: properties.actionProperties, second: eventWithActionProperties.actionProperties, from1Over2: rewriteEvent)
            event = eventWithActionProperties
        }
        if var eventWithAdvertisementProperties = event as? TrackingEventWithAdvertisementProperties {
            eventWithAdvertisementProperties.advertisementProperties = mergeTool.mergeProperties(first: properties.advertisementProperties, second: eventWithAdvertisementProperties.advertisementProperties, from1Over2: rewriteEvent)
            event = eventWithAdvertisementProperties
        }
        if var eventWithEcommerceProperties = event as? TrackingEventWithEcommerceProperties {
            eventWithEcommerceProperties.ecommerceProperties = mergeTool.mergeProperties(first: properties.ecommerceProperties, second: eventWithEcommerceProperties.ecommerceProperties, from1Over2: rewriteEvent)
            event = eventWithEcommerceProperties
        }
        if var eventWithMediaProperties = event as? TrackingEventWithMediaProperties {
            eventWithMediaProperties.mediaProperties = mergeTool.mergeProperties(first: properties.mediaProperties, second: eventWithMediaProperties.mediaProperties, from1Over2: rewriteEvent)
            event = eventWithMediaProperties
        }
        if var eventWithPageProperties = event as? TrackingEventWithPageProperties {
            eventWithPageProperties.pageProperties = mergeTool.mergeProperties(first: properties.pageProperties, second: eventWithPageProperties.pageProperties, from1Over2: rewriteEvent)
            event = eventWithPageProperties
        }
        if var eventWithSessionDetails = event as? TrackingEventWithSessionDetails {
            eventWithSessionDetails.sessionDetails = mergeTool.mergeProperties(first: properties.sessionDetails, second: eventWithSessionDetails.sessionDetails, from1Over2: rewriteEvent)
            event = eventWithSessionDetails
        }
        if var eventWithUserProperties = event as? TrackingEventWithUserProperties {
            eventWithUserProperties.userProperties = mergeTool.mergeProperties(first: properties.userProperties, second: eventWithUserProperties.userProperties, from1Over2: rewriteEvent)
            event = eventWithUserProperties
        }
        
        return event
    }
    
    private func applyKeys(keys: [String:String], properties: BaseProperties) -> BaseProperties{
        
        guard let trackingParameter = properties.trackingParameters else {
            WebtrekkTracking.defaultLogger.logError("no tracking parameters for properties")
            return properties
        }
        
        if let globalProperties = properties as? GlobalProperties {
            return GlobalProperties(actionProperties: trackingParameter.actionProperties(variables: keys),
                                    advertisementProperties: trackingParameter.advertisementProperties(variables: keys),
                                    crossDeviceProperties: globalProperties.crossDeviceProperties,
                                    ecommerceProperties: trackingParameter.ecommerceProperties(variables: keys),
                                    ipAddress: trackingParameter.resolveIPAddress(variables: keys),
                                    mediaProperties: trackingParameter.mediaProperties(variables: keys),
                                    pageProperties: trackingParameter.pageProperties(variables: keys),
                                    sessionDetails: trackingParameter.sessionDetails(variables: keys),
                                    userProperties: trackingParameter.userProperties(variables: keys),
                                    variables: globalProperties.variables)
        } else if let pageProperties = properties as? TrackerConfiguration.Page {
            
            var page = trackingParameter.pageProperties(variables: keys)
            //override name from xml
            page.name = pageProperties.pageProperties.name
            
            return TrackerConfiguration.Page(viewControllerTypeNamePattern: pageProperties.viewControllerTypeNamePattern,
                                             pageProperties: page,
                                             actionProperties: trackingParameter.actionProperties(variables: keys),
                                             advertisementProperties: trackingParameter.advertisementProperties(variables: keys),
                                             ecommerceProperties: trackingParameter.ecommerceProperties(variables: keys),
                                             ipAddress: trackingParameter.resolveIPAddress(variables: keys),
                                             mediaProperties: trackingParameter.mediaProperties(variables: keys),
                                             sessionDetails: trackingParameter.sessionDetails(variables: keys),
                                             userProperties: trackingParameter.userProperties(variables: keys))
        } else {
            WebtrekkTracking.logger.logError("Unsupported type of properties")
            return properties
        }
    }
    
    /** get and set everID. If you set Ever ID it started to use new value for all requests*/
    var everId: String {
        get {
            checkIsOnMainThread()
            
            // cash ever id in internal parameter to avoid multiple request to setting.
            if everIdInternal == nil {
                
                everIdInternal = DefaultTracker.sharedDefaults.stringForKey(DefaultsKeys.everId)
                
                //generate ever id if it isn't exist
                return everIdInternal ?? {
                    let everId = String(format: "6%010.0f%08lu", arguments: [Date().timeIntervalSince1970, arc4random_uniform(99999999) + 1])
                    DefaultTracker.sharedDefaults.set(key: DefaultsKeys.everId, to: everId)
                    return everId
                    }()
            } else {
                return everIdInternal!
            }
        }
        
        set(newEverID) {
            checkIsOnMainThread()
            
            //check if ever id has correct format
            if let isMatched = newEverID.isMatchForRegularExpression("\\d{19}") , isMatched {
                // set ever id value in setting and in cash
                DefaultTracker.sharedDefaults.set(key: DefaultsKeys.everId, to: newEverID)
                self.everIdInternal = newEverID
            } else {
                WebtrekkTracking.defaultLogger.logError("Incorrect ever id format: \(newEverID)")
            }
        }
    }
    
    //cash for ever id
    private var everIdInternal: String?
    
    private var isFirstEventAfterAppUpdate: Bool {
		didSet {
			checkIsOnMainThread()

			guard isFirstEventAfterAppUpdate != oldValue else {
				return
			}

			defaults.set(key: DefaultsKeys.isFirstEventAfterAppUpdate, to: isFirstEventAfterAppUpdate)
		}
	}


	private var isFirstEventOfApp: Bool {
		didSet {
			checkIsOnMainThread()

			guard isFirstEventOfApp != oldValue else {
				return
			}

			defaults.set(key: DefaultsKeys.isFirstEventOfApp, to: isFirstEventOfApp)
		}
	}


	internal static var isOptedOut = DefaultTracker.loadIsOptedOut() {
		didSet {
			checkIsOnMainThread()

			isOptedOutWasSetManually = true

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
	private static var isOptedOutWasSetManually = false


	private static func loadIsOptedOut() -> Bool {
		checkIsOnMainThread()

		return sharedDefaults.boolForKey(DefaultsKeys.isOptedOut) ?? false
	}


	private func loadRequestQueue() {
		checkIsOnMainThread()

		guard !requestQueueLoaded else {
			return
		}

		requestQueueLoaded = true

		guard let file = requestQueueBackupFile else {
			return
		}

		let fileManager = FileManager.default
		guard fileManager.itemExistsAtURL(file) else {
			return
		}

		guard !DefaultTracker.isOptedOut else {
			do {
				try fileManager.removeItem(at: file)
				logDebug("Ignored request queue at '\(file)': User opted out of tracking.")
			}
			catch let error {
				logError("Cannot remove request queue at '\(file)': \(error)")
			}

			return
		}

		let queue: [URL]
		do {
			let data = try Data(contentsOf: file, options: [])

			let object: AnyObject?
			if #available(iOS 9.0, *) {
				object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as NSData)
			}
			else {
				object = NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject?
			}

			guard let _queue = object as? [URL] else {
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


	#if !os(watchOS) && !os(tvOS)
	private func retrieveConnectionType() -> TrackerRequest.Properties.ConnectionType? {
		guard let reachability = Reachability.init() else {
			return nil
		}
		if reachability.isReachableViaWiFi {
			return .wifi
		}
		else if reachability.isReachableViaWWAN {
			if let carrierType = CTTelephonyNetworkInfo().currentRadioAccessTechnology {
				switch carrierType {
				case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
					return .cellular_2G

				case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
					return .cellular_3G

				case CTRadioAccessTechnologyLTE:
					return .cellular_4G

				default:
					return .other
				}
			}
			else {
				return .other
			}
		}
		else if reachability.isReachable {
			return .other
		}
		else {
			return .offline
		}
	}
	#endif


	private static func requestQueueBackupFileForWebtrekkId(_ webtrekkId: String) -> URL? {
		checkIsOnMainThread()

		let searchPathDirectory: FileManager.SearchPathDirectory
		#if os(iOS) || os(OSX) || os(watchOS)
			searchPathDirectory = .applicationSupportDirectory
		#elseif os(tvOS)
			searchPathDirectory = .cachesDirectory
		#endif

		let fileManager = FileManager.default

		var directory: URL
		do {
			directory = try fileManager.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		}
		catch let error {
			logError("Cannot find directory for storing request queue backup file: \(error)")
			return nil
		}

		directory = directory.appendingPathComponent("Webtrekk")
		directory = directory.appendingPathComponent(webtrekkId)

		if !fileManager.itemExistsAtURL(directory) {
			do {
				try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [URLResourceKey.isExcludedFromBackupKey.rawValue: true])
			}
			catch let error {
				logError("Cannot create directory at '\(directory)' for storing request queue backup file: \(error)")
				return nil
			}
		}

		return directory.appendingPathComponent("requestQueue.archive")
	}


	internal func sendPendingEvents() {
		checkIsOnMainThread()

		startRequestManager()

		requestManager.sendAllRequests()
	}


	private func setUp() {
		checkIsOnMainThread()

		#if !os(watchOS)
			setUpObservers()
			updateAutomaticTracking()
            setupAutoDeepLinkTrack()
		#endif

		updateSampling()
	}


	#if !os(watchOS)
	private func setUpObservers() {
		checkIsOnMainThread()

		let notificationCenter = NotificationCenter.default
		applicationDidBecomeActiveObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
			self?.applicationDidBecomeActive()
		}
		applicationWillEnterForegroundObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillEnterForeground()
		}
		applicationWillResignActiveObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
			self?.applicationWillResignActive()
		}
	}
	#endif


	private var shouldEnqueueNewEvents: Bool {
		checkIsOnMainThread()

		return isSampling && !DefaultTracker.isOptedOut
	}


	fileprivate func saveRequestQueue() {
		checkIsOnMainThread()

		guard let file = requestQueueBackupFile else {
			return
		}
		guard requestQueueLoaded || !requestManager.queue.isEmpty else {
			return
		}

		// make sure backup is loaded before overwriting it
		loadRequestQueue()

		let queue = requestManager.queue
		guard !queue.isEmpty else {
			let fileManager = FileManager.default
			if fileManager.itemExistsAtURL(file) {
				do {
					try FileManager.default.removeItem(at: file)
					logDebug("Deleted request queue at '\(file).")
				}
				catch let error {
					logError("Cannot remove request queue at '\(file)': \(error)")
				}
			}

			return
		}

		let data = NSKeyedArchiver.archivedData(withRootObject: queue)
		do {
			try data.write(to: file, options: .atomicWrite)
			logDebug("Saved \(queue.count) queued request(s) to '\(file).")
		}
		catch let error {
			logError("Cannot save request queue to '\(file)': \(error)")
		}
	}


	fileprivate func startRequestManager() {
		checkIsOnMainThread()

		requestManagerStartTimer?.invalidate()
		requestManagerStartTimer = nil

		guard !requestManager.started else {
			return
		}

		#if !os(watchOS)
			guard application.applicationState == .active else {
				return
			}
		#endif

		loadRequestQueue()
		requestManager.start()
	}


	fileprivate func stopRequestManager() {
		checkIsOnMainThread()

		guard requestManager.started else {
			return
		}

		requestManager.stop()
		saveRequestQueue()
	}


	internal func trackAction(_ event: ActionEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	internal func trackMediaAction(_ event: MediaEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	internal func trackPageView(_ event: PageViewEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	
	internal func trackerForMedia(_ mediaName: String, pageName: String) -> MediaTracker {
		checkIsOnMainThread()

		return DefaultMediaTracker(handler: self, mediaName: mediaName, pageName: pageName)
	}


	#if !os(watchOS)
	internal func trackerForMedia(_ mediaName: String, pageName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker {
		checkIsOnMainThread()

		let tracker = trackerForMedia(mediaName, pageName: pageName)
		AVPlayerTracker.track(player: player, with: tracker)

		return tracker
	}
	#endif


	
	internal func trackerForPage(_ pageName: String) -> PageTracker {
		checkIsOnMainThread()

		return DefaultPageTracker(handler: self, pageName: pageName)
	}

    #if !os(watchOS)
    fileprivate func setupAutoDeepLinkTrack()
    {
        //init deep link to get automatic object
        deepLink.deepLinkInit()
    }
    #endif
    

	#if !os(watchOS)
	fileprivate func updateAutomaticTracking() {
		checkIsOnMainThread()

		let handler = DefaultTracker._autotrackingEventHandler

		if configuration.automaticallyTrackedPages.isEmpty {
			if let index = handler.trackers.index(where: { [weak self] in $0 === self}) {
				handler.trackers.remove(at: index)
			}
		}
		else {
			if !handler.trackers.contains(where: {[weak self] in $0 === self }) {
				handler.trackers.append(WeakReference(self))
			}

			UIViewController.setUpAutomaticTracking()
		}
	}
	#endif


	private func updateConfiguration() {
		checkIsOnMainThread()

		guard let updateUrl = configuration.configurationUpdateUrl else {
			return
		}

		let _ = requestManager.fetch(url: updateUrl) { data, error in
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
		checkIsOnMainThread()

		if let isSampling = defaults.boolForKey(DefaultsKeys.isSampling), let samplingRate = defaults.intForKey(DefaultsKeys.samplingRate) , samplingRate == configuration.samplingRate {
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


    static let userAgent: String = {
		checkIsOnMainThread()

		let properties = [
			Environment.deviceModelString,
            Environment.operatingSystemName + " " + Environment.operatingSystemVersionString,
			Locale.current.identifier
			].joined(separator: "; ")

		return "Tracking Library \(WebtrekkTracking.version) (\(properties))"
	}()


	private static func validatedConfiguration(_ configuration: TrackerConfiguration) -> TrackerConfiguration {
		checkIsOnMainThread()

		var configuration = configuration
		var problems = [String]()
		var isError = false

		if configuration.webtrekkId.isEmpty {
			configuration.webtrekkId = "ERROR"
			problems.append("webtrekkId must not be empty!! -> changed to 'ERROR'")

			isError = true
		}

		#if !os(watchOS)
			var pageIndex = 0
			configuration.automaticallyTrackedPages = configuration.automaticallyTrackedPages.filter { page in
				defer { pageIndex += 1 }

				guard page.pageProperties.name?.nonEmpty != nil else {
					problems.append("automaticallyTrackedPages[\(pageIndex)] must not be empty")
					return false
				}

				return true
			}
		#endif

		func checkProperty<Value: Comparable>(_ name: String, value: Value, allowedValues: ClosedRange<Value>) -> Value {
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
		configuration.resendOnStartEventTime = checkProperty("resendOnStartEventTime", value: configuration.resendOnStartEventTime, allowedValues: TrackerConfiguration.allowedResendOnStartEventTimes)
		configuration.version                = checkProperty("version",                value: configuration.version,                allowedValues: TrackerConfiguration.allowedVersions)

		if !problems.isEmpty {
			(isError ? logError : logWarning)("Illegal values in tracker configuration: \(problems.joined(separator: ", "))")
		}

		return configuration
	}


	private func validateEvent(_ event: TrackingEvent) -> Bool {
		checkIsOnMainThread()

		guard event.pageName?.nonEmpty != nil else {
			logError("Cannot track event without .pageName set: \(event)")
			return false
		}

		if let event = event as? TrackingEventWithActionProperties {
			guard event.actionProperties.name?.nonEmpty != nil else {
				logError("Cannot track event without .actionProperties.name set: \(event)")
				return false
			}
		}

		if let event = event as? TrackingEventWithMediaProperties {
			guard event.mediaProperties.name?.nonEmpty != nil else {
				logError("Cannot track event without .mediaProperties.name set: \(event)")
				return false
			}
		}

		return true
	}
    
    /** set media code. Media code will be sent with next page request only. Only setter is working. Getter always returns ""d*/
    var mediaCode: String {
        get {
            return ""
        }
        
        set (newMediaCode) {
            checkIsOnMainThread()
            deepLink.setMediaCode(newMediaCode)
        }
    }
    
}


extension DefaultTracker: ActionEventHandler {

	internal func handleEvent(_ event: ActionEvent) {
		checkIsOnMainThread()

		enqueueRequestForEvent(event)
	}
}


extension DefaultTracker: MediaEventHandler {

	internal func handleEvent(_ event: MediaEvent) {
		checkIsOnMainThread()

		enqueueRequestForEvent(event)
	}
}


extension DefaultTracker: PageViewEventHandler {

	internal func handleEvent(_ event: PageViewEvent) {
		checkIsOnMainThread()

		enqueueRequestForEvent(event)
	}
}


extension DefaultTracker: RequestManager.Delegate {

	internal func requestManager(_ requestManager: RequestManager, didFailToSendRequest request: URL, error: RequestManager.ConnectionError) {
		checkIsOnMainThread()

		requestManagerDidFinishRequest()
	}


	internal func requestManager(_ requestManager: RequestManager, didSendRequest request: URL) {
		checkIsOnMainThread()

		requestManagerDidFinishRequest()
	}


	private func requestManagerDidFinishRequest() {
		checkIsOnMainThread()

		saveRequestQueue()

		#if !os(watchOS)
			if requestManager.queue.isEmpty {
				if backgroundTaskIdentifier != UIBackgroundTaskInvalid {
					application.endBackgroundTask(backgroundTaskIdentifier)
					backgroundTaskIdentifier = UIBackgroundTaskInvalid
				}

				if application.applicationState != .active {
					stopRequestManager()
				}
			}
		#endif
	}
}



#if !os(watchOS)
	private final class AutotrackingEventHandler: ActionEventHandler, MediaEventHandler, PageViewEventHandler {

		fileprivate var trackers = [WeakReference<DefaultTracker>]()


		private func broadcastEvent<Event: TrackingEvent>(_ event: Event, handler: (DefaultTracker) -> (Event) -> Void) {
			var event = event

			for trackerOpt in trackers {
				guard let viewControllerType = event.viewControllerType, let tracker = trackerOpt.target
					, tracker.configuration.automaticallyTrackedPageForViewControllerType(viewControllerType) != nil
				else {
					continue
				}

				handler(tracker)(event)
			}
		}


		fileprivate func handleEvent(_ event: ActionEvent) {
			checkIsOnMainThread()

			broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
		}


		fileprivate func handleEvent(_ event: MediaEvent) {
			checkIsOnMainThread()

			broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
		}


		fileprivate func handleEvent(_ event: PageViewEvent) {
			checkIsOnMainThread()

			broadcastEvent(event, handler: DefaultTracker.handleEvent(_:))
		}
	}
#endif



struct DefaultsKeys {

	fileprivate static let appHibernationDate = "appHibernationDate"
	fileprivate static let appVersion = "appVersion"
	fileprivate static let configuration = "configuration"
	static let everId = "everId"
	fileprivate static let isFirstEventAfterAppUpdate = "isFirstEventAfterAppUpdate"
	fileprivate static let isFirstEventOfApp = "isFirstEventOfApp"
	fileprivate static let isSampling = "isSampling"
	fileprivate static let isOptedOut = "optedOut"
	fileprivate static let migrationCompleted = "migrationCompleted"
	fileprivate static let samplingRate = "samplingRate"
}

private extension TrackingValue {
    
    mutating func resolve(variables: [String: String]) -> Bool {
        switch self {
        case let .customVariable(key):
            if let value = variables[key] {
                self = .constant(value)
                return true
            }
        default:
            return false
        }
        return false
    }
    
}

private class PropertyMerger {
    
    func mergeProperties(first property1: ActionProperties, second property2: ActionProperties, from1Over2: Bool) -> ActionProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: AdvertisementProperties, second property2: AdvertisementProperties, from1Over2: Bool) -> AdvertisementProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: EcommerceProperties, second property2: EcommerceProperties, from1Over2: Bool) -> EcommerceProperties{
        
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: MediaProperties, second property2: MediaProperties, from1Over2: Bool) -> MediaProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: PageProperties, second property2: PageProperties, from1Over2: Bool) -> PageProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: [Int: TrackingValue], second property2: [Int: TrackingValue], from1Over2: Bool) -> [Int: TrackingValue]{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: UserProperties, second property2: UserProperties, from1Over2: Bool) -> UserProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
}
