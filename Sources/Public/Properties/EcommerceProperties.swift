public struct EcommerceProperties {

	public var categories: Set<Category>?
	public var currencyCode: String?
	public var orderNumber: String?
	public var products: [Product]?
	public var status: Status?
	public var totalValue: Double?
	public var voucherValue: Double?


	public init(
		categories: Set<Category>? = nil,
		currencyCode: String? = nil,
		products: [Product]? = nil,
		status: Status? = nil,
		totalValue: Double? = nil,
		voucherValue: Double? = nil
	) {
		self.categories = categories
		self.currencyCode = currencyCode
		self.products = products
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}

	
	@warn_unused_result
	internal func merged(with other: EcommerceProperties) -> EcommerceProperties {
		return EcommerceProperties(
			categories:   categories ?? other.categories,
			currencyCode: currencyCode ?? other.currencyCode,
			products:     products ?? other.products,
			status:       status ?? other.status,
			totalValue:   totalValue ?? other.totalValue,
			voucherValue: voucherValue ?? other.voucherValue
		)
	}



	public struct Product {

		public var categories: Set<Category>?
		public var name: String
		public var price: String?
		public var quantity: Int?

		public init(
			name: String,
			categories: Set<Category>? = nil,
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
