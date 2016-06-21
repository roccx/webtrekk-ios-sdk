public struct EcommerceProperties {

	public var currency: String?
	public var categories: Set<Category> = []
	public var orderNumber: String?
	public var status: Status
	public var totalValue: Double
	public var voucherValue: Double?


	public init(totalValue: Double, status: Status = .view) {
		self.status = status
		self.totalValue = totalValue
	}



	public enum Status: String {

		case add
		case conf
		case view
	}
}
