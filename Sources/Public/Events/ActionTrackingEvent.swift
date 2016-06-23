public struct ActionTrackingEvent {

	public var actionProperties: ActionProperties
	public var ecommerceProperties: EcommerceProperties
	public var pageProperties: PageProperties


	public init(
		actionProperties: ActionProperties,
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),

	) {
		self.actionProperties = actionProperties
	}
}
