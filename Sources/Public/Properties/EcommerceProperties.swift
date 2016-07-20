public struct EcommerceProperties {

	public var currencyCode: String?
	public var details: [Int: TrackingValue]?
	public var orderNumber: String?
	public var products: [Product]?
	public var status: Status?
	public var totalValue: String?
	public var voucherValue: String?


	public init(
		currencyCode: String? = nil,
		details: [Int: TrackingValue]? = nil,
		orderNumber: String? = nil,
		products: [Product]? = nil,
		status: Status? = nil,
		totalValue: String? = nil,
		voucherValue: String? = nil
	) {
		self.currencyCode = currencyCode
		self.details = details
		self.orderNumber = orderNumber
		self.products = products
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}

	
	@warn_unused_result
	internal func merged(over other: EcommerceProperties) -> EcommerceProperties {
		return EcommerceProperties(
			currencyCode: currencyCode ?? other.currencyCode,
			details:      details.merged(over: other.details),
			products:     products ?? other.products,
			status:       status ?? other.status,
			totalValue:   totalValue ?? other.totalValue,
			voucherValue: voucherValue ?? other.voucherValue
		)
	}



	public struct Product {

		public var categories: [Int: TrackingValue]?
		public var name: String
		public var price: String?
		public var quantity: Int?

		public init(
			name: String,
			categories: [Int: TrackingValue]? = nil,
		    price: String? = nil,
			quantity: Int? = nil
		) {
			self.categories = categories
			self.name = name
			self.price = price
			self.quantity = quantity
		}
	}



	public enum Status {

		case addedToBasket
		case purchased
		case viewed
	}
}
