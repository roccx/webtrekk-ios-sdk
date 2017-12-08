///The MIT License (MIT)
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
//  Created by arsen.vartbaronov on 29/11/17.
//
import XCTest
import Nimble
import Webtrekk

class ProductListTest: WTBaseTestNew{
    
    var mainViewController: ViewController!
    
    override func getConfigName() -> String?{
        return String("webtrekk_config_product_list")
    }
    
    func testManual(){
        let productListTracking = WebtrekkTracking.instance().productListTracker
        
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }
        
        // tracks products
        
        var product1 = getProductWithInd(ind: 1)
        product1.price = nil
        product1.priceNum = nil
        var product2 = getProductWithInd(ind: 2)
        var product3 = EcommerceProperties.Product(name: "productId3")
        product3.position = 3
        var product4 = getProductWithInd(ind: 4)
        
        productListTracking.addTrackingData(products: [product1, product2, product3, product4], type: .list)
        
         doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.93,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["p"]).to(contain("pageName"))
            expect(parameters["st"]).to(equal("list"))
            
            expect(parameters["cb1"]).to(equal(product1.getDetails(1)+";"+product2.getDetails(1)+";;"+product4.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product1.getDetails(2)+";"+product2.getDetails(2)+";;"+product4.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product1.getCat(1)+";"+product2.getCat(1)+";;"+product4.getCat(1)))
            expect(parameters["ca2"]).to(equal(product1.getCat(2)+";"+product2.getCat(2)+";;"+product4.getCat(2)))
            expect(parameters["ba"]).to(equal(product1.getName()+";"+product2.getName()+";productId3;"+product4.getName()))
            expect(parameters["plp"]).to(equal(product1.getPosition()+";"+product2.getPosition()+";3;"+product4.getPosition()))
            expect(parameters["co"]).to(equal(";"+product2.getPriceNum()+";;"+product4.getPriceNum()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.93"))
            expect(parameters["cb765"]).to(equal(product1.getGrosMargin()+";"+product2.getGrosMargin()+";;"+product4.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product1.getVariant()+";"+product2.getVariant()+";;"+product4.getVariant()))
            expect(parameters["cb760"]).to(equal(product1.getSoldOut()+";"+product2.getSoldOut()+";;"+product4.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product1.getVoucher()+";"+product2.getVoucher()+";;"+product4.getVoucher()))
        }
        // track product2 position one more time
        product2.position = 5
        productListTracking.addTrackingData(products: [product2], type: .list)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: [1: "override"],
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.936,
                                                                                                               orderStatus: "orderStatus")),
                                                                      viewController: self.mainViewController)
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["p"]).to(contain("autoPageName"))
            expect(parameters["st"]).to(equal("list"))
            expect(parameters["cb1"]).to(equal("override"))
            expect(parameters["ca1"]).to(equal(product2.getCat(1)))
            expect(parameters["ca2"]).to(equal(product2.getCat(2)))
            expect(parameters["ba"]).to(equal(product2.getName()))
            expect(parameters["plp"]).to(equal(product2.getPosition()))
            expect(parameters["co"]).to(equal(product2.getPriceNum()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.936"))
            expect(parameters["cb765"]).to(equal(product2.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product2.getVariant()))
            expect(parameters["cb760"]).to(equal(product2.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product2.getVoucher()))
        }
        
        //view product 1
         product1 = getProductWithInd(ind: 1)
         productListTracking.addTrackingData(products: [product1], type: .viewed)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: "voucherOver",
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.1,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("view"))
            expect(parameters["cb1"]).to(equal(product1.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product1.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product1.getCat(1)))
            expect(parameters["ca2"]).to(equal(product1.getCat(2)))
            expect(parameters["ba"]).to(equal(product1.getName()))
            expect(parameters["plp"]).to(equal(product1.getPosition()))
            expect(parameters["co"]).to(equal(product1.getPrice()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.1"))
            expect(parameters["cb765"]).to(equal(product1.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product1.getVariant()))
            expect(parameters["cb760"]).to(equal(product1.getSoldOut()))
            expect(parameters["cb563"]).to(equal("voucherOver"))
        }
        
        //view product 2
        product2.position = nil
        productListTracking.addTrackingData(products: [product2], type: .viewed)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("view"))
            expect(parameters["cb1"]).to(equal(product2.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product2.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product2.getCat(1)))
            expect(parameters["ca2"]).to(equal(product2.getCat(2)))
            expect(parameters["ba"]).to(equal(product2.getName()))
            expect(parameters["plp"]).to(equal("5"))
            expect(parameters["co"]).to(equal(product2.getPriceNum()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.0"))
            expect(parameters["cb765"]).to(equal(product2.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product2.getVariant()))
            expect(parameters["cb760"]).to(equal(product2.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product2.getVoucher()))
        }
        
        //add product 2
        product2.position = nil
        productListTracking.addTrackingData(products: [product2], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.3335,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("add"))
            expect(parameters["cb1"]).to(equal(product2.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product2.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product2.getCat(1)))
            expect(parameters["ca2"]).to(equal(product2.getCat(2)))
            expect(parameters["ba"]).to(equal(product2.getName()))
            expect(parameters["plp"]).to(equal("2"))
            expect(parameters["co"]).to(equal(product2.getPriceNum()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.3335"))
            expect(parameters["cb765"]).to(equal(product2.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product2.getVariant()))
            expect(parameters["cb760"]).to(equal(product2.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product2.getVoucher()))
        }
        
        //add product1
        product1.position = nil
        productListTracking.addTrackingData(products: [product1], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.3335,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("add"))
            expect(parameters["cb1"]).to(equal(product1.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product1.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product1.getCat(1)))
            expect(parameters["ca2"]).to(equal(product1.getCat(2)))
            expect(parameters["ba"]).to(equal(product1.getName()))
            expect(parameters["plp"]).to(equal("1"))
            expect(parameters["co"]).to(equal(product1.getPrice()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.3335"))
            expect(parameters["cb765"]).to(equal(product1.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product1.getVariant()))
            expect(parameters["cb760"]).to(equal(product1.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product1.getVoucher()))
        }
        
        //add product7
        let product7 = EcommerceProperties.Product(name: "productId7")
        productListTracking.addTrackingData(products: [product7], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.3335,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("add"))
            expect(parameters["cb1"]).to(beNil())
            expect(parameters["cb2"]).to(beNil())
            expect(parameters["ca1"]).to(beNil())
            expect(parameters["ca2"]).to(beNil())
            expect(parameters["ba"]).to(equal(product7.getName()))
            expect(parameters["plp"]).to(beNil())
            expect(parameters["co"]).to(beNil())
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.3335"))
            expect(parameters["cb765"]).to(beNil())
            expect(parameters["cb767"]).to(beNil())
            expect(parameters["cb760"]).to(beNil())
            expect(parameters["cb563"]).to(beNil())
        }
        
        //add product4
        product4.position = nil
        productListTracking.addTrackingData(products: [product4], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.3335,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){_ in }
        
        //conf request
        product1.position = nil
        product2.position = nil
        product4.position = nil
        
        productListTracking.addTrackingData(products: [product1, product2, product7, product4], type: .purchased)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName"),
                                                                      ecommerceProperties: EcommerceProperties(currencyCode: nil,
                                                                                                               details: nil,
                                                                                                               orderNumber: "orderNumber",
                                                                                                               products: nil,
                                                                                                               status: nil,
                                                                                                               totalValue: "totalValue",
                                                                                                               voucherValue: nil,
                                                                                                               paymentMethod: "paymentMethod",
                                                                                                               shippingService: "shippingService",
                                                                                                               shippingSpeed: "shippingSpeed",
                                                                                                               shippingCost: 9.3335,
                                                                                                               orderStatus: "orderStatus")))
        }
        
        doURLSendTestCheck(){parameters in
            expect(parameters["p"]).to(contain("pageName"))
            expect(parameters["st"]).to(equal("conf"))
            
            expect(parameters["cb1"]).to(equal(product2.getDetails(1)+";"+product1.getDetails(1)+";;"+product4.getDetails(1)))
            expect(parameters["cb2"]).to(equal(product2.getDetails(2)+";"+product1.getDetails(2)+";;"+product4.getDetails(2)))
            expect(parameters["ca1"]).to(equal(product2.getCat(1)+";"+product1.getCat(1)+";;"+product4.getCat(1)))
            expect(parameters["ca2"]).to(equal(product2.getCat(2)+";"+product1.getCat(2)+";;"+product4.getCat(2)))
            expect(parameters["ba"]).to(equal(product2.getName()+";"+product1.getName()+";"+product7.getName()+";"+product4.getName()))
            expect(parameters["plp"]).to(equal("2;1;;4"))
            expect(parameters["co"]).to(equal(product2.getPriceNum()+";"+product1.getPrice()+";;"+product4.getPriceNum()))
            expect(parameters["cb761"]).to(equal("paymentMethod"))
            expect(parameters["cb762"]).to(equal("shippingService"))
            expect(parameters["cb763"]).to(equal("shippingSpeed"))
            expect(parameters["cb766"]).to(equal("orderStatus"))
            expect(parameters["ov"]).to(equal("totalValue"))
            expect(parameters["cb764"]).to(equal("9.3335"))
            expect(parameters["cb765"]).to(equal(product2.getGrosMargin()+";"+product1.getGrosMargin()+";;"+product4.getGrosMargin()))
            expect(parameters["cb767"]).to(equal(product2.getVariant()+";"+product1.getVariant()+";;"+product4.getVariant()))
            expect(parameters["cb760"]).to(equal(product2.getSoldOut()+";"+product1.getSoldOut()+";;"+product4.getSoldOut()))
            expect(parameters["cb563"]).to(equal(product2.getVoucher()+";"+product1.getVoucher()+";;"+product4.getVoucher()))
            expect(parameters["qn"]).to(equal("3;2;;5"))
        }


    }
    
    
    func testSaveOrderData(){
        var productListTracking = WebtrekkTracking.instance().productListTracker
        var product5 = getProductWithInd(ind: 5)
        var product6 = getProductWithInd(ind: 6)
        
        // track list
        productListTracking.addTrackingData(products: [product5, product6], type: .list)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
       doURLSendTestCheck(){_ in }
        // track add
        product5.position = nil
        product6.position = nil
        
        productListTracking.addTrackingData(products: [product6, product5], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }

        self.doURLSendTestCheck(){_ in }
        
        // restart Webtrekk
        self.releaseWebtrekk()
        self.initWebtrekk()
        
        productListTracking = WebtrekkTracking.instance().productListTracker
        
        var product7 = getProductWithInd(ind: 7)
 
        // track product7
        productListTracking.addTrackingData(products: [product7], type: .list)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
        doURLSendTestCheck(){_ in }
        
        //add product 7
        product7.position = nil
        
        productListTracking.addTrackingData(products: [product7], type: .addedToBasket)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
        self.doURLSendTestCheck(){_ in }
        
        // conf purchase
        
        productListTracking.addTrackingData(products: [product7, product5, product6], type: .purchased)
  
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }

        
        doURLSendTestCheck(){parameters in
            expect(parameters["st"]).to(equal("conf"))
            expect(parameters["ba"]).to(equal(product6.getName() + ";" + product5.getName()+";" + product7.getName()))
            expect(parameters["plp"]).to(equal("6;5;7"))
        }
    }
    
    func testDataSize(){
        //test 255 size
        let productListTracking = WebtrekkTracking.instance().productListTracker
        var fieldSize = 0
        let maxFieldSize = 600
        var products = [EcommerceProperties.Product]()
        var ind = 0
        
        repeat{
            let product = getProductWithInd(ind: ind)
            ind = ind + 1
            fieldSize = fieldSize + getProductMaxFieldSize(product: product)
            products.append(product)
        }while fieldSize < maxFieldSize
        
        productListTracking.addTrackingData(products: products, type: .list)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
        let lock = NSLock()
        var finishWait = false
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            let position = String(describing: ind - 1)
            
            parameters.forEach(){ key, value in

                expect(value.count).to(beLessThan(256), description: "for parameter \(key) value \(value) has more then 255 characters ")
                if key == "plp" {
                    value.split(separator: ";").forEach(){item in
                        finishWait = (position == String (describing: item))
                    }
                }
            }
        }
        
        expect(finishWait).toEventually(equal(true), timeout:10000)
        
        self.httpTester.removeStub()
        self.httpTester.addStandardStub()
        
        productListTracking.addTrackingData(products: [products[0]], type: .purchased)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
        self.doURLSendTestCheck(){_ in }
        
        let value200Length = String(repeating: "a", count: 200)// because ; is added
        
        //test 8 kB
        
        var productsLongURL = [EcommerceProperties.Product]()
        let maxProductsNum = 50
        finishWait = false
        
        
        for i in 0 ..< maxProductsNum {
            var product = self.getProductWithInd(ind: i)
            product.details = [Int: TrackingValue]()
            product.categories = [Int: TrackingValue]()
            product.details?[i] = .constant(value200Length)
            product.categories?[i] = .constant(value200Length)
            productsLongURL.append(product)
        }
        
        productListTracking.addTrackingData(products: productsLongURL, type: .list)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }

        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            
            let lenght = query.url!.absoluteString.count
            
            WebtrekkTracking.defaultLogger.logDebug("url length is \(lenght)")
            expect(lenght).to(beLessThan(1024*8), description: "string is more then 8196 length")

            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            parameters.forEach(){ key, value in
                if key == "ba" {
                    value.split(separator: ";").forEach(){item in
                        finishWait = (productsLongURL[maxProductsNum - 1].getName() == String (describing: item))
                    }
                }
            }
        }
        
        expect(finishWait).toEventually(equal(true), timeout:10000)
        
        self.httpTester.removeStub()
        self.httpTester.addStandardStub()
        
        // reset add values
        productListTracking.addTrackingData(products: [products[0]], type: .purchased)
        
        doURLSendTestAction(){
            productListTracking.track(commonProperties: PageViewEvent(pageProperties: PageProperties(name: "pageName")))
        }
        
        self.doURLSendTestCheck(){_ in }
    }

    
    private func getProductWithInd(ind: Int) -> EcommerceProperties.Product {
        return EcommerceProperties.Product(name: "productId\(ind)",
            categories: [1: .constant("cat\(ind)1"), 2: .constant("cat\(ind)2")],
            price: ind % 2 == 0 ? nil : String(describing :13.5 + Float(ind)),
            priceNum: 14.5 + Float(ind),
            quantity: ind + 1,
            position: ind,
            details: [1: .constant("ecom\(ind)1"), 2: .constant("ecom\(ind)2")],
            grossMargin: 33.5 + Float(ind),
            productVariant: "variant\(ind)",
            voucherValue: "voucher\(ind)",
            soldOut: ind % 2 == 0)
    }
    
    private func getProductMaxFieldSize(product: EcommerceProperties.Product) -> Int{
    
    func getMaxSize(dictionary:[Int: TrackingValue]) -> Int{
        var maxSize = 0
        
        dictionary.forEach(){key, value in
            if let value = value.value, value.count > maxSize {
                maxSize = value.count
            }
        }
        
        return maxSize
    }

        var maxSize = 0;
        if let details = product.details, maxSize < getMaxSize(dictionary: details) {
            maxSize = getMaxSize(dictionary: details)
        } else if let categories = product.categories, maxSize < getMaxSize(dictionary: categories) {
            maxSize = getMaxSize(dictionary: categories)
        }else if let name = product.name, maxSize < name.count {
            maxSize = name.count
        }else if let _ = product.priceNum, maxSize < product.getPriceNum().count {
            maxSize = product.getPriceNum().count
        }else if let price = product.price, maxSize < price.count {
            maxSize = price.count
        }else if let variant = product.variant, maxSize < variant.count {
            maxSize = variant.count
        }else if let voucher = product.voucher, maxSize < voucher.count {
            maxSize = voucher.count
        }else if let _ = product.grossMargin, maxSize < product.getGrosMargin().count {
            maxSize = product.getGrosMargin().count
        }else if let _ = product.position, maxSize < product.getPosition().count {
            maxSize = product.getPosition().count
        }
        return maxSize
    }
}


extension TrackingValue {
    var value: String? {
        switch self {
        case let .constant(value):
            return value
        default:
            return nil
        }
    }
}

extension EcommerceProperties.Product {
    func getDetails(_ ind: Int) -> String {
        guard let value = self.details?[ind]?.value else {
            return "nil"
        }
        return value
    }
    
    func getCat(_ ind: Int) -> String {
        guard let value = self.categories?[ind]?.value else {
            return "nil"
        }
        return value
    }
    
    func getName() -> String{
        guard let value = self.name else {
            return "nil"
        }
        return value
    }
    
    func getPosition() -> String{
        guard let value = self.position else {
            return "nil"
        }
        return String(describing: value)
    }
    func getPrice() -> String{
        guard let value = self.price else {
            return "nil"
        }
        return value
    }
    func getPriceNum() -> String{
        guard let value = self.priceNum else {
            return "nil"
        }
        return String(describing: value)
    }
    func getGrosMargin() -> String{
        guard let value = self.grossMargin else {
            return "nil"
        }
        return String(describing: value)
    }
    func getVariant() -> String{
        guard let value = self.variant else {
            return "nil"
        }
        return value
    }
    func getSoldOut() -> String{
        guard let value = self.soldOut else {
            return "nil"
        }
        return value ? "1" : "0"
    }
    
    func getVoucher() -> String{
        guard let value = self.voucher else {
            return "nil"
        }
        return value
    }
}


