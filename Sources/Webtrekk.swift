import UIKit


public final class Webtrekk {

	var config: TrackerConfiguration
	private var plugins = Set<Plugin>()
	private var hibernationObserver: NSObjectProtocol?
	private var wakeUpObserver: NSObjectProtocol?
	

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
		setUpOptedOut()
		setUpLifecycleObserver()
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


	public func handleAfterPluginCall(trackingParameter: TrackingParameter) {
		for plugin in plugins {
			plugin.afterTrackingSend(trackingParameter)
		}
	}

	// TODO: Consider if plugins can change the trackingParameter, as to add more default parameters or change others. use inout if needed

	public func handleBeforePluginCall(trackingParameter: TrackingParameter) {
		for plugin in plugins {
			plugin.beforeTrackingSend(trackingParameter)
		}
	}

}
