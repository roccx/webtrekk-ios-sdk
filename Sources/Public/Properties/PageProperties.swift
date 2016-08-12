import UIKit


public struct PageProperties {

	public var details: [Int: TrackingValue]?
	public var groups: [Int: TrackingValue]?
	public var name: String?
	public var internalSearch: String?
 	public var url: String?
	public var viewControllerType: UIViewController.Type?
    var internalSearchConfig: PropertyValue?


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
    
    
    init(
        nameComplex: String?,
        details: [Int: TrackingValue]? = nil,
        groups: [Int: TrackingValue]? = nil,
        internalSearchConfig: PropertyValue? = nil,
        url: String? = nil
        ) {
        self.details = details
        self.groups = groups
        self.name = nameComplex
        self.internalSearchConfig = internalSearchConfig
        self.url = url
    }
	
	@warn_unused_result
    internal func merged(over other: PageProperties) -> PageProperties {
		var new = self
		new.details = details.merged(over: other.details)
		new.groups = groups.merged(over: other.groups)
		new.name = name ?? other.name
        new.internalSearchConfig = internalSearchConfig ?? other.internalSearchConfig
        new.internalSearch = internalSearch ?? other.internalSearch
		new.viewControllerType = viewControllerType ?? other.viewControllerType
		new.url = url ?? other.url
		return new
	}
    
    mutating func processKeys(event: TrackingEvent)
    {
        if let internalSearch = internalSearchConfig?.serialized(for: event) {
            self.internalSearch = internalSearch
        }
    }
}
