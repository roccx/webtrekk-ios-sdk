//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//


import Foundation

public struct EcommerceProperties {

	public var currencyCode: String?
	public var details: [Int: TrackingValue]?
	public var orderNumber: String?
	public var products: [Product]?
	public var status: Status?
	public var totalValue: String?
	public var voucherValue: String?

	public init(
		currencyCode: String? = nil,
		details: [Int: TrackingValue]? = nil,
		orderNumber: String? = nil,
		products: [Product]? = nil,
		status: Status? = nil,
		totalValue: String? = nil,
		voucherValue: String? = nil
	) {
		self.currencyCode = currencyCode
		self.details = details
		self.orderNumber = orderNumber
		self.products = products
		self.status = status
		self.totalValue = totalValue
		self.voucherValue = voucherValue
	}

	internal func merged(over other: EcommerceProperties) -> EcommerceProperties {
		return EcommerceProperties(
			currencyCode: currencyCode ?? other.currencyCode,
			details:      details.merged(over: other.details),
			orderNumber:  orderNumber ?? other.orderNumber,
			products:     mergedProducts(products: products, over: other.products),
			status:       status ?? other.status,
			totalValue:   totalValue ?? other.totalValue,
			voucherValue: voucherValue ?? other.voucherValue
		)
	}
    
    internal func mergedProducts(products: [Product]?, over: [Product]?) -> [Product]?{
        
        guard let products = products else {
            return over
        }
        
        guard let over = over else {
            return products
        }
        var names: [String] = [] , overNames: [String] = [], mergedNames: [String]
        var prices: [String] = [], overPrices: [String] = [], mergedPrices : [String]
        var quantities : [Int] = [], overQuantities : [Int] = [], mergedQuantities : [Int]
        var categories: [[Int: TrackingValue]] = [], overCategories: [[Int: TrackingValue]] = [], mergedCategories: [[Int: TrackingValue]] = []

        transformFromProductList(products: products, names: &names, prices: &prices, quantities: &quantities, categories: &categories)
        transformFromProductList(products: over, names: &overNames, prices: &overPrices, quantities: &overQuantities, categories: &overCategories)
        
        mergedNames = !names.isEmpty ? names : overNames
        mergedPrices = !prices.isEmpty ? prices : overPrices
        mergedQuantities = !quantities.isEmpty ? quantities : overQuantities
        
        for cat in categories {
            overCategories.forEach{mergedCategories.append(cat.merged(over: $0))}
        }
        
        return transformToProductList(names: mergedNames, prices: mergedPrices, quantities: mergedQuantities, categories: mergedCategories)
    }
    
    private func transformFromProductList(products: [Product], names: inout [String], prices: inout [String], quantities: inout [Int], categories localCategories: inout [[Int: TrackingValue]]){
        
        guard products.count > 0 else {
            return
        }
        
        for product in products {
            if let name = product.name , !name.isEmpty {
                names.append(name)
            }
            if let price = product.price {
                prices.append(price)
            }
            if let quantity = product.quantity {
                quantities.append(quantity)
            }
            if let categories = product.categories {
                localCategories.append(categories)
            }
        }
    }
    
    // assume that array is size of names size
    private func transformToProductList(names: [String], prices: [String], quantities: [Int],
                                  categories: [[Int: TrackingValue]]) -> [Product]? {
       
        let size = max (names.count, prices.count, quantities.count, !categories.isEmpty ? 1 : 0)
        
        guard size > 0 else {
            return nil
        }
        
        var products: [Product] = []
        
        for i in 0..<size {
            products.append(Product(name: names.count > i ? names[i]: "",
                categories: categories.count > i ? categories[i] : nil,
                price: prices.count > i ? prices[i]: nil,
                quantity: quantities.count > i ? quantities[i] : nil))
        }
        
        return products
    }

	public struct Product {

		public var categories: [Int: TrackingValue]?
		public var name: String?
		public var price: String?
		public var quantity: Int?

		public init(
			name: String,
			categories: [Int: TrackingValue]? = nil,
		    price: String? = nil,
			quantity: Int? = nil
		) {
			self.categories = categories
			self.name = name
			self.price = price
			self.quantity = quantity
		}

        
        
		internal func merged(over other: Product) -> Product {
            var new = Product(name: "")
            
            new.name = name ?? other.name
            new.categories = categories.merged(over: other.categories)
            new.price = price ?? other.price
            new.quantity = quantity ?? other.quantity
            return new
		}
    }

    public enum Status: String{
		case addedToBasket = "add"
		case purchased = "conf"
		case viewed = "view"
	}
}

extension String  {
    var isQuantity : Bool {
        get{
            return characters.count > 0 && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
