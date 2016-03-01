import Foundation

public struct EcommerceParameter {
	public var currency:     String
	public var details:      [Int: String]
	public var orderNumber:  String
	public var status:       EcommerceStatus
	public var totalValue:   Double
	public var voucherValue: Double?

	public init(currency: String = "", details: [Int: String] = [Int:String](), orderNumber: String = "", status: EcommerceStatus = .VIEW, totalValue: Double, voucherValue: Double?) {
		self.currency = currency
		self.details = details
		self.orderNumber = orderNumber
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}
}

public enum EcommerceStatus: String {
	case ADD  = "add"
	case CONF = "conf"
	case VIEW = "view"
}