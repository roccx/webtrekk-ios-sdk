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
//  Created by Widget Labs
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
    var currencyCodeConfig: PropertyValue?
    var orderNumberConfig: PropertyValue?
    var statusConfig: PropertyValue?
    var voucherValueConfig: PropertyValue?
    var totalValueConfig: PropertyValue?
    var productConf: Product?


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

    init(
        currencyCodeConfig: PropertyValue?,
        details: [Int: TrackingValue]? = nil,
        orderNumberConfig:PropertyValue? = nil,
        products: [Product]? = nil,
        statusConfig: PropertyValue? = nil,
        totalValueConfig: PropertyValue? = nil,
        voucherValueConfig: PropertyValue? = nil,
        productConf: Product? = nil
        ) {
        self.currencyCodeConfig = currencyCodeConfig
        self.details = details
        self.orderNumberConfig = orderNumberConfig
        self.products = products
        self.statusConfig = statusConfig
        self.totalValueConfig = totalValueConfig
        self.voucherValueConfig = voucherValueConfig
        self.productConf = productConf
    }
	
	@warn_unused_result
	internal func merged(over other: EcommerceProperties) -> EcommerceProperties {
		var new = EcommerceProperties(
			currencyCode: currencyCode ?? other.currencyCode,
			details:      details.merged(over: other.details),
			orderNumber:  orderNumber ?? other.orderNumber,
			products:     products ?? other.products,
			status:       status ?? other.status,
			totalValue:   totalValue ?? other.totalValue,
			voucherValue: voucherValue ?? other.voucherValue
		)
        new.currencyCodeConfig = currencyCodeConfig ?? other.currencyCodeConfig
        new.orderNumberConfig = orderNumberConfig ?? other.orderNumberConfig
        new.statusConfig = statusConfig ?? other.statusConfig
        new.totalValueConfig = totalValueConfig ?? other.totalValueConfig
        new.voucherValueConfig = voucherValueConfig ?? other.voucherValueConfig
        new.productConf = productConf ?? other.productConf
        return new
	}



	public struct Product {

		public var categories: [Int: TrackingValue]?
		public var name: String?
		public var price: String?
		public var quantity: Int?
        var nameConfig: PropertyValue?
        var priceConfig: PropertyValue?
        var quantityConfig: PropertyValue?

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


        init(
            nameConfig: PropertyValue? = nil,
            categories: [Int: TrackingValue]? = nil,
            priceConfig: PropertyValue? = nil,
            quantityConfig: PropertyValue? = nil
            ) {
            self.categories = categories
            self.nameConfig = nameConfig
            self.priceConfig = priceConfig
            self.quantityConfig = quantityConfig
        }
		
        
        @warn_unused_result
		internal func merged(over other: Product) -> Product {
			var new = Product()
            
            new.name = name ?? other.name
            new.categories = categories.merged(over: other.categories)
            new.price = price ?? other.price
            new.quantity = quantity ?? other.quantity
            new.nameConfig = nameConfig ?? other.nameConfig
            new.priceConfig = priceConfig ?? other.priceConfig
            new.quantityConfig = quantityConfig ?? other.quantityConfig
            return new
		}
        
        
        private mutating func processKeys(event: TrackingEvent){
            if let name = nameConfig?.serialized(for: event) {
                self.name = name
            }
            if let price = priceConfig?.serialized(for: event) {
                self.price = price
            }
            
            if let quantity = self.quantityConfig?.serialized(for: event) {
                    if quantity.isQuantity{
                        self.quantity = Int(quantity)
                    }
            }
        }
	}

    public enum Status: String{
		case addedToBasket = "add"
		case purchased = "conf"
		case viewed = "view"
	}
    
    mutating func processKeys(event: TrackingEvent){
        if let currencyCode = currencyCodeConfig?.serialized(for: event) {
            self.currencyCode = currencyCode
        }
        if let orderNumber = orderNumberConfig?.serialized(for: event) {
            self.orderNumber = orderNumber
        }
        if let staus = statusConfig?.serialized(for: event) {
                self.status = Status(rawValue: staus)
        }
        
        if let totalValue = totalValueConfig?.serialized(for: event) {
            self.totalValue = totalValue
        }
        
        if let voucherValue = voucherValueConfig?.serialized(for: event) {
            self.voucherValue = voucherValue
        }
        
        if let _ = self.productConf {
            self.productConf?.processKeys(event)
        }
//            if let _ = self.products{
//                for (index, value) in (self.products?.enumerate())! {
//                    var productNew = self.productConf!
//                    productNew.merged(over: value)
//                    self.products?[index] = productNew
//                }
//            }else {
//                self.products?.append(self.productConf!)
//            }
//        }
    }
}

private extension String  {
    var isQuantity : Bool {
        get{
            return characters.count > 0 && self.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) == nil
        }
    }
}
