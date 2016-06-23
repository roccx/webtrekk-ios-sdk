import UIKit


public struct PageProperties {

	public var categories: Set<Category>?
	public var name: String?
	public var viewControllerType: UIViewController.Type?


	public init(
		name: String,
		categories: Set<Category>? = nil
	) {
		self.categories = categories
		self.name = name
	}


	public init(
		viewControllerType: UIViewController.Type,
		categories: Set<Category>? = nil
	) {
		self.categories = categories
		self.viewControllerType = viewControllerType
	}
}
