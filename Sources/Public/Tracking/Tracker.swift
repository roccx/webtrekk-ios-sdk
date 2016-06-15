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
	private let loger: Loger
	private let webtrekk: Webtrekk

	public init(webtrekk: Webtrekk, loger: Loger = Loger()) {
		self.loger = loger
		self.webtrekk = webtrekk
	}


	public func didShow() {
		if isVisible {
			loger.log("Can't track view of screen \(name) which is already visible.")
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
			loger.log("Screen name not set when tracking action \(action)")
			return
		}
		if !isVisible {
			loger.log("Can't track action \(action) for screen \(name) which isn't visible.")
			return
		}

		guard let tracking = tracking else {
			webtrekk.track(name, trackingParameter: ActionTracking(actionParameter: ActionParameter(name: action)))
			return
		}
		var actionTracking = tracking
		actionTracking.actionParameter?.name = action
		webtrekk.track(name, trackingParameter: actionTracking)
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
			webtrekk.track(name)
			return
		}

		webtrekk.track(name, trackingParameter: pageTracking)
	}
}