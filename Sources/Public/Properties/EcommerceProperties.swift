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
