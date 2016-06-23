import UIKit


public struct PageProperties {

	public var categories: Set<Category>?
	public var name: String?
	public var viewControllerTypeName: String?


	public init(
		name: String?,
		categories: Set<Category>? = nil
	) {
		self.categories = categories
		self.name = name
	}


	public init(
		viewControllerTypeName: String?,
		categories: Set<Category>? = nil
	) {
		self.categories = categories
		self.viewControllerTypeName = viewControllerTypeName
	}

	
	@warn_unused_result
	internal func merged(with other: PageProperties) -> PageProperties {
		var new = self
		new.categories = categories ?? other.categories
		new.name = name ?? other.name
		new.viewControllerTypeName = viewControllerTypeName ?? other.viewControllerTypeName
		return new
	}
}
