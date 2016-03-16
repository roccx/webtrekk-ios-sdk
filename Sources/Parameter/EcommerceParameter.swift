import Foundation

public struct EcommerceParameter {
	public var currency:     String
	public var categories:   [Int: String]
	public var orderNumber:  String
	public var status:       EcommerceStatus
	public var totalValue:   Double
	public var voucherValue: Double?

	public init(categories: [Int: String] = [Int:String](), currency: String = "", orderNumber: String = "", status: EcommerceStatus = .VIEW, totalValue: Double, voucherValue: Double? = nil) {
		self.currency = currency
		self.categories = categories
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

extension EcommerceParameter: Parameter {
	internal var urlParameter: String {
		get {
			var urlParameter = ""
			if !currency.isEmpty {
				urlParameter += ParameterName.urlParameter(fromName: .EcomCurrency, andValue: currency)
			}

			if !categories.isEmpty {
				for (index, value) in categories {

					urlParameter += "&\(ParameterName.urlParameter(fromName: .EcomCategory, withIndex: index, andValue: value))"
				}
			}
			return urlParameter
		}
	}
}