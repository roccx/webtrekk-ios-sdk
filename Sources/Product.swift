import Foundation

public struct Product {

	public let name:      String
	public var categories: [String]
	public var currency:  String?
	public let price:     Double?
	public let amount:    Int?

	public init(amount: Int? = nil, categories: [String] = [], currency: String? = nil, name: String, price: Double? = nil) {
		self.amount = amount
		self.categories = categories
		self.currency = currency
		self.name = name
		self.price = price
	}
}

