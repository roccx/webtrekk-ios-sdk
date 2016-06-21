public struct PageTrackingEvent {

	public var ecommerceProperties: EcommerceProperties?
	public var pageProperties: PageProperties


	public init(pageProperties: PageProperties) {
		self.pageProperties = pageProperties
	}
}
