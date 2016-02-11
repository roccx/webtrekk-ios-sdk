import Foundation

public struct ProductParameter {
	public private(set) var products = [Product]()

	public init(product: Product){
		self.products.append(product)
	}

	public init(products:[Product]){
		self.products.appendContentsOf(products)
	}


}

extension ProductParameter: Parameter {


	public var queryItems: [NSURLQueryItem] {
		get {
			var names = ""
			var prices = ""
			var amounts = ""
			var categories = [String]()
			for product in products {
				names += ";\(product.name)"
				prices += ";\(product.price != nil ? String(product.price) : "")"
				amounts += ";\(product.amount != nil ? String(product.amount) : "")"
				for (index, categorie) in product.categories.enumerate() {
					categories[index] += ";\(categorie)"
				}
			}
			names = names.substringWithRange(names.startIndex.advancedBy(1)..<names.endIndex)
			prices = prices.substringWithRange(prices.startIndex.advancedBy(1)..<prices.endIndex)
			amounts = amounts.substringWithRange(amounts.startIndex.advancedBy(1)..<amounts.endIndex)
			var controlString = products.reduce(""){acc,_ in return acc + ";"}
			controlString = controlString.substringWithRange(controlString.startIndex.advancedBy(1)..<controlString.endIndex)
			var items = [NSURLQueryItem(name: "ba", value: names)]
			if controlString != prices {
				items.append(NSURLQueryItem(name: "co", value: prices))
			}
			if controlString != amounts {
				items.append(NSURLQueryItem(name: "qn", value: amounts))
			}
			categories.enumerate().map{ (index, element) in NSURLQueryItem(name: "ca\(index + 1)", value: element)}
			return items.filter({!$0.value!.isEmpty})
		}
	}

	func combinator(accumulator: String, current: String) -> String {
		return "\(accumulator);\(current)"
	}
}