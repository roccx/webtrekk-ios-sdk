public struct EcommerceProperties {

	public var currencyCode: String?
	public var details: Set<IndexedProperty>?
	public var orderNumber: String?
	public var products: [Product]?
	public var status: Status?
	public var totalValue: Double?
	public var voucherValue: Double?


	public init(
		currencyCode: String? = nil,
		details: Set<IndexedProperty>? = nil,
		products: [Product]? = nil,
		status: Status? = nil,
		totalValue: Double? = nil,
		voucherValue: Double? = nil
	) {
		self.currencyCode = currencyCode
		self.details = details
		self.products = products
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}

	
	@warn_unused_result
	internal func merged(with other: EcommerceProperties) -> EcommerceProperties {
		return EcommerceProperties(
			currencyCode: currencyCode ?? other.currencyCode,
			details:      details ?? other.details,
			products:     products ?? other.products,
			status:       status ?? other.status,
			totalValue:   totalValue ?? other.totalValue,
			voucherValue: voucherValue ?? other.voucherValue
		)
	}



	public struct Product {

		public var categories: Set<IndexedProperty>?
		public var name: String
		public var price: String?
		public var quantity: Int?

		public init(
			name: String,
			categories: Set<IndexedProperty>? = nil,
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
