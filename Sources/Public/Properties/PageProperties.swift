import UIKit


public struct PageProperties {

	public var details: [Int: TrackingValue]?
	public var groups: [Int: TrackingValue]?
	public var name: String?
	public var internalSearch: String?
	public var url: String?
	public var viewControllerType: UIViewController.Type?


	public init(
		name: String?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		internalSearch: String? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.name = name
		self.internalSearch = internalSearch
		self.url = url
	}


	public init(
		viewControllerType: UIViewController.Type?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		internalSearch: String? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.internalSearch = internalSearch
		self.url = url
		self.viewControllerType = viewControllerType
	}

	
	@warn_unused_result
	internal func merged(over other: PageProperties) -> PageProperties {
		var new = self
		new.details = details.merged(over: other.details)
		new.groups = groups.merged(over: other.groups)
		new.name = name ?? other.name
		new.internalSearch = internalSearch ?? other.internalSearch
		new.viewControllerType = viewControllerType ?? other.viewControllerType
		new.url = url ?? other.url
		return new
	}
}
