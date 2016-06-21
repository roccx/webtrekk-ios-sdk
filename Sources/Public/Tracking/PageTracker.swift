public protocol PageTracker: ActionTracker {

	var properties: PageProperties { get set }

	func didShow        ()
	func updateWithName (properties: PageProperties)
	func willHide       ()
}
