import Foundation

public protocol ProductParameter {
	var categories: [Int: String] { get set }
	var currency:   String        { get set }
	var name:       String        { get set }
	var price:      String        { get set }
	var quantity:   String        { get set }
}

internal struct DefaultProductParameter: ProductParameter {
	internal var categories: [Int: String]
	internal var currency:   String
	internal var name:       String
	internal var price:      String
	internal var quantity:   String

	internal init(categories: [Int: String] = [Int: String](), currency: String = "", name: String, price: String = "", quantity: String = "") {
		self.categories = categories
		self.currency = currency
		self.name = name
		self.price = price
		self.quantity = quantity
	}

}

internal extension ProductParameter {
	internal func equal(rhs: ProductParameter) -> Bool {
		let lhs = self
		guard lhs.categories == rhs.categories else {
			return false
		}

		guard lhs.currency == rhs.currency else {
			return false
		}

		guard lhs.name == rhs.name else {
			return false
		}

		guard lhs.price == rhs.price else {
			return false
		}

		guard lhs.quantity == rhs.quantity else {
			return false
		}
		
		return true
	}
}
