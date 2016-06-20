import Foundation

public protocol ActionTracker: class {

	func trackAction (action: String)
	func trackAction (action: String, tracking: ActionTracking)
}

public protocol ScreenTracker: ActionTracker {

	var name: String { get }
	var pageTracking: PageTracking? { get }

	func didShow        ()
	func updateWithName (name: String)
	func updateWithName (name: String, pageTracking: PageTracking?)
	func willHide       ()
}

public final class DefaultScreenTracker: ScreenTracker {

	private(set) public var name = ""
	private(set) public var pageTracking: PageTracking?

	private var isVisible = false
	private let tracker: Webtrekk


	public init(tracker: Webtrekk) {
		self.tracker = tracker
	}


	public func didShow() {
		if isVisible {
			tracker.logWarning("Can't track view of screen \(name) which is already visible.")
			return
		}
		isVisible = true

		trackScreenView()
	}


	public func trackAction(action: String) {
		trackAction(action, tracking: nil)
	}


	public func trackAction(action: String, tracking: ActionTracking) {
		trackAction(action, tracking: Optional(tracking))
	}


	private func trackAction(action: String, tracking: ActionTracking?) {
		precondition(!action.isEmpty)

		if name.isEmpty {
			tracker.logWarning("Screen name not set when tracking action \(action)")
			return
		}
		if !isVisible {
			tracker.logWarning("Can't track action \(action) for screen \(name) which isn't visible.")
			return
		}

		guard let tracking = tracking else {
			tracker.track(name, trackingParameter: ActionTracking(actionParameter: ActionParameter(name: action)))
			return
		}
		var actionTracking = tracking
		actionTracking.actionParameter?.name = action
		tracker.track(name, trackingParameter: actionTracking)
	}


	public func updateWithName(name: String) {
		updateWithName(name, pageTracking: nil)
	}


	public func updateWithName(name: String, pageTracking: PageTracking?) {
		if name == self.name { //&& pageTracking == self.pageTracking {
			return
		}

		self.name = name
		self.pageTracking = pageTracking

		trackScreenView()
	}


	public func willHide() {
		isVisible = false
	}


	private func trackScreenView(){
		if !isVisible || name.isEmpty {
			return
		}

		guard let pageTracking = pageTracking else {
			tracker.track(name)
			return
		}

		tracker.track(name, trackingParameter: pageTracking)
	}
}
