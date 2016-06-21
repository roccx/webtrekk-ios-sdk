import Foundation


internal final class DefaultPageTracker: PageTracker {

	internal var properties: PageProperties

	private var isVisible = false
	private let parent: Webtrekk

	
	internal init(parent: Webtrekk, properties: PageProperties) {
		self.parent = parent
		self.properties = properties
	}


	internal func didShow() {
		if isVisible {
			parent.logger.logWarning("Can't track view of screen \(properties.pageName) which is already visible.")
			return
		}
		isVisible = true

		trackScreenView()
	}


	internal func trackAction(event: ActionTrackingEvent) {
		parent.track(event)
	}


	internal func updateWithName(properties: PageProperties) {
		if properties == self.properties {
			return
		}

		self.properties = properties

		trackScreenView()
	}


	internal func willHide() {
		isVisible = false
	}


	private func trackScreenView(){
		if !isVisible || properties.pageName.isEmpty {
			return
		}


//		tracker.track(name, trackingParameter: pageTracking)
	}
}
