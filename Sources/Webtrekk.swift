import UIKit

public final class Webtrekk : Logable {

	internal lazy var loger: Loger = Loger(trackingId: self.config.trackingId)
	public var advertisingIdentifier: (() -> String?)? {
		didSet {
			queue?.advertisingIdentifier = advertisingIdentifier
		}
	}

	public var enableLoging: Bool = false {
		didSet {
			guard oldValue != enableLoging else {
				return
			}
			loger.enabled = enableLoging
		}
	}

	public var config: TrackerConfiguration {
		didSet {
			guard oldValue.optedOut != config.optedOut else {
				return
			}
			queue?.shouldTrack = shouldTrack()

		}
	}

	public var flush: Bool = false{
		didSet {
			if flush {
				self.flush = false
				queue?.flushNow()
			}
		}
	}

	public var crossDeviceBridge: CrossDeviceBridgeParameter?

	private var plugins = Set<Plugin>()
	private var hibernationObserver: NSObjectProtocol?
	private var wakeUpObserver: NSObjectProtocol?
	private var queue: WebtrekkQueue?
	private lazy var fileManager: FileManager = FileManager(self.loger)

	// MARK: Lifecycle

	deinit {
		if let hibernationObserver = hibernationObserver {
			NSNotificationCenter.defaultCenter().removeObserver(hibernationObserver)
		}
		if let wakeUpObserver = wakeUpObserver {
			NSNotificationCenter.defaultCenter().removeObserver(wakeUpObserver)
		}
	}


	public convenience init(configParser: ConfigParser){
		self.init(config: configParser.trackerConfiguration)
	}


	public init(config: TrackerConfiguration) {
		self.config = config
		setUp()
	}


	private func setUp() {
		setUpConfig()
		setUpQueue()
		setUpOptedOut()
		setUpLifecycleObserver()
	}


	private func setUpConfig() {
		// check if there is a local dump of the config saved
		if let localConfig = fileManager.restoreConfiguration(config.trackingId) where localConfig.version > config.version{
			config = localConfig
		}
		else {
			fileManager.saveConfiguration(config)
		}

		guard config.enableRemoteConfiguration && !config.remoteConfigurationUrl.isEmpty, let url = NSURL(string: config.remoteConfigurationUrl) else {
			return
		}

		let httpClient = DefaultHttpClient()
		httpClient.get(url) { (data, error) -> Void in
			guard let xmlData = data else {
				self.log("No data could be retrieved from \(self.config.remoteConfigurationUrl).")
				return
			}
			guard let xmlString = String(data: xmlData, encoding: NSUTF8StringEncoding) else {
				self.log("Cannot parse data retreived from \(self.config.remoteConfigurationUrl)")
				return
			}

			let config = XmlConfigParser(xmlString: xmlString).trackerConfiguration

			guard config.version > self.config.version else {
				self.log("Remote configuration is not newer then the currently used.")
				return
			}
			self.log("Updating tracker config from version \(self.config.version) to new version \(config.version)")
			self.config = config
			self.fileManager.saveConfiguration(config)
		}
	}


	private func setUpLifecycleObserver() {
		hibernationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			_ in // TODO: notifiy that app will enter background
		}

		wakeUpObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			_ in // TODO: notifiy that app will enter foreground
		}
	}


	private func setUpOptedOut() {
		config.optedOut =	NSUserDefaults.standardUserDefaults().boolForKey(UserStoreKey.OptedOut)
	}


	private func setUpQueue() {
		let backupFileUrl: NSURL = fileManager.getConfigurationDirectoryUrl(forTrackingId: config.trackingId).URLByAppendingPathComponent("queue.json")
		queue = WebtrekkQueue(backupFileUrl: backupFileUrl, sendDelay: config.sendDelay, maximumUrlCount: config.maxRequests, loger: loger)
		queue?.shouldTrack = shouldTrack()
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

	// MARK: Tracking

	public func auto(className: String) {
		guard config.autoTrack else {
			return
		}

		for (key, screen) in config.autoTrackScreens {
			guard className.containsString(key) else {
				continue
			}
			guard screen.enabled else {
				return
			}
			track(screen)
			return
		}
		track(className)
	}


	public func track(pageName: String) {
		track(PageTrackingParameter(pageName: pageName))
	}


	public func track(trackingParameter: TrackingParameter) {
		var preparedConfig = config
		if let crossDeviceBridge = crossDeviceBridge {
			preparedConfig.crossDeviceParameters = crossDeviceBridge.toParameter()
		}
		enqueue(trackingParameter, config: preparedConfig)
	}


	private func track(screen: AutoTrackedScreen) {
		if let pageTrackingParameter = screen.pageTrackingParameter {
			track(pageTrackingParameter)
		}
		else {
			track(screen.mappingName)
		}
	}


	private func enqueue(trackingParameter: TrackingParameter, config: TrackerConfiguration) {
		queue?.add(trackingParameter, config: config)
	}

	// MARK: Plugins

	public func addPlugin(plugin: Plugin){
		guard !plugins.contains(plugin) else {
			fatalError("The Plugin with the id:\"\(plugin.id)\" was already added.")
		}

		plugins.insert(plugin)

	}


	public func removePlugin(plugin: Plugin) -> Bool {
		return plugins.remove(plugin) == plugin
	}


	public func removeAllPlugins() -> Bool {
		plugins.removeAll()
		return plugins.isEmpty
	}
	
}
