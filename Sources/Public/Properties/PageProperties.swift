import UIKit


public struct PageProperties {

	public var details: [Int: TrackingValue]?
	public var groups: [Int: TrackingValue]?
	public var name: String?
	public var viewControllerTypeName: String?
	public var url: String?


	public init(
		name: String?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.name = name
		self.url = url
	}


	public init(
		viewControllerTypeName: String?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.viewControllerTypeName = viewControllerTypeName
		self.url = url
	}

	
	@warn_unused_result
	internal func merged(over other: PageProperties) -> PageProperties {
		var new = self
		new.details = details.merged(over: other.details)
		new.groups = groups.merged(over: other.groups)
		new.name = name ?? other.name
		new.viewControllerTypeName = viewControllerTypeName ?? other.viewControllerTypeName
		new.url = url ?? other.url
		return new
	}
}
