import Foundation

public protocol EcommerceParameter {
	var currency:     String          { get set }
	var details:      [Int: String]   { get set }
	var orderNumber:  String          { get set }
	var status:       EcommerceStatus { get set }
	var totalValue:   Double          { get set }
	var voucherValue: Double?         { get set }
}

public enum EcommerceStatus: String {
	case ADD  = "add"
	case CONF = "conf"
	case VIEW = "view"
}


internal struct DefaultEcommerceParameter: EcommerceParameter {
	internal var currency:     String
	internal var details:      [Int: String]
	internal var orderNumber:  String
	internal var status:       EcommerceStatus
	internal var totalValue:   Double
	internal var voucherValue: Double?

	internal init(currency: String = "", details: [Int: String] = [Int:String](), orderNumber: String = "", status: EcommerceStatus = .VIEW, totalValue: Double, voucherValue: Double?) {
		self.currency = currency
		self.details = details
		self.orderNumber = orderNumber
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}
}