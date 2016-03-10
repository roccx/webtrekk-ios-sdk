import UIKit


public final class Webtrekk {

	var config: TrackerConfiguration
	private var plugins = Set<Plugin>()
	private var hibernationObserver: NSObjectProtocol?
	private var wakeUpObserver: NSObjectProtocol?
	private var queue: WebtrekkQueue?
	private lazy var fileManager = FileManager()

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
		// TODO: check if there is a local dump of the config saved
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
				log("No data could be retrieved from \(self.config.remoteConfigurationUrl).")
				return
			}
			guard let xmlString = String(data: xmlData, encoding: NSUTF8StringEncoding) else {
				log("Cannot retrieve data retreived from \(self.config.remoteConfigurationUrl)")
				return
			}

			let config = XmlConfigParser(xmlString: xmlString).trackerConfiguration

			guard config.version > self.config.version else {
				log("Remote configuration is not newer then the currently used.")
				return
			}
			log("Updating tracker config from version \(self.config.version) to new version \(config.version)")
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
		// TODO: generate backup File url
		let backupFileUrl = NSURL()
		queue = WebtrekkQueue(backupFileUrl: backupFileUrl, sendDelay: config.sendDelay, maximumUrlCount: config.maxRequests)
	}


	// MARK: Tracking

	public func track(pageName: String) {
		var trackingParameter = PageTrackingParameter(pageParameter: PageParameter())
		trackingParameter.pixelParameter.pageName = pageName
		track(trackingParameter)
	}


	public func track(trackingParameter: TrackingParameter) {
		enqueue(trackingParameter, config: config)
	}

	private func enqueue(trackingParameter: TrackingParameter, config: TrackerConfiguration) {
		// TODO: add to queue
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
