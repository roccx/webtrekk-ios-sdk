import UIKit


public struct PageProperties {

	public var details: Set<IndexedProperty>?
	public var groups: Set<IndexedProperty>?
	public var name: String?
	public var viewControllerTypeName: String?


	public init(
		name: String?,
		details: Set<IndexedProperty>? = nil,
		groups: Set<IndexedProperty>? = nil
	) {
		self.details = details
		self.groups = groups
		self.name = name
	}


	public init(
		viewControllerTypeName: String?,
		details: Set<IndexedProperty>? = nil,
		groups: Set<IndexedProperty>? = nil
		) {
		self.details = details
		self.groups = groups
		self.viewControllerTypeName = viewControllerTypeName
	}

	
	@warn_unused_result
	internal func merged(with other: PageProperties) -> PageProperties {
		var new = self
		new.details = details ?? other.details
		new.groups = groups ?? other.groups
		new.name = name ?? other.name
		new.viewControllerTypeName = viewControllerTypeName ?? other.viewControllerTypeName
		return new
	}
}
