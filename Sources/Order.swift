import Foundation

public struct Order {

	public var currency: String?
	public var number:   String?
	public var total:    Double
	public var voucher:  Double?


	public init(currency: String? = nil, number: String? = nil, total: Double, voucher: Double? = nil) {
		self.currency = currency
		self.number = number
		self.total = total
		self.voucher = voucher
	}
}
