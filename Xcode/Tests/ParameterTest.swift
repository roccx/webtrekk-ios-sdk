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
//  Created by arsen.vartbaronov on 17/08/16.
//

import XCTest
import Nimble
import Webtrekk

class ParameterTest: WTBaseTestNew {
    
    var mainViewController: ViewController!
    
    
    override func getConfigName() -> String?{
        return String("webtrekk_config_no_autoTrack")
    }

    
    func testVariablesParameterGlobal()
    {
        
                doURLSendTestAction(){
                     let tracker = WebtrekkTracking.instance()
//                     tracker["ADVERTISEMENT"]="ADVERTISEMENT"
//                     tracker["ADVERTISEMENT_ACTION"]="ADVERTISEMENT_ACTION"
                     tracker["BIRTHDAY"]="19761008"
//                     tracker["CITY"]="CITY"
//                     tracker["COUNTRY"]="COUNTRY"
                     tracker["CURRENCY"]="CURRENCY"
                     tracker["CUSTOMER_ID"]="CUSTOMER_ID"
                     tracker["EMAIL"]="EMAIL"
                     tracker["EMAIL_RID"]="EMAIL_RID"
//                     tracker["GNAME"]="GNAME"
                     tracker["GENDER"]="1"
                     tracker["INTERN_SEARCH"]="INTERN_SEARCH"
//                     tracker["IP_ADDRESS"]="IP_ADDRESS"
//                     tracker["SNAME"]="SNAME"
//                     tracker["NEWSLETTER"]="NEWSLETTER"
                     //tracker["ORDER_NUMBER"]="ORDER_NUMBER"
//                     tracker["PAGE_URL"]="PAGE_URL"
//                     tracker["PHONE"]="PHONE"
                     //tracker["PRODUCT"]="PRODUCT"
                     //tracker["PRODUCT_COST"]="PRODUCT_COST"
                     //tracker["PRODUCT_COUNT"]="2"
                     //tracker["PRODUCT_STATUS"]="conf"
//                     tracker["STREET"]="STREET"
//                     tracker["STREETNUMBER"]="STREETNUMBER"
                     //tracker["ORDER_TOTAL"]="ORDER_TOTAL"
                     //tracker["VOUCHER_VALUE"]="VOUCHER_VALUE"
//                     tracker["ZIP"]="ZIP"
                       tracker.trackPageView("somePageName")
                }
        
                self.timeout = 10
                doURLSendTestCheck(){parametersArr in
//                    expect(parametersArr["mc"]).to(equal("ADVERTISEMENT"))
//                    expect(parametersArr["mca"]).to(equal("ADVERTISEMENT_ACTION"))
                    expect(parametersArr["uc707"]).to(equal("19761008"))
//                    expect(parametersArr["uc708"]).to(equal("CITY"))
//                    expect(parametersArr["uc709"]).to(equal("COUNTRY"))
                    expect(parametersArr["cr"]).to(equal("CURRENCY"))
                    expect(parametersArr["cd"]).to(equal("CUSTOMER_ID"))
                    expect(parametersArr["uc700"]).to(equal("EMAIL"))
                    expect(parametersArr["uc701"]).to(equal("EMAIL_RID"))
//                    expect(parametersArr["uc703"]).to(equal("GNAME"))
                    expect(parametersArr["uc706"]).to(equal("1"))
                    expect(parametersArr["is"]).to(equal("INTERN_SEARCH"))
//                    expect(parametersArr["X_WT_IP"]).to(equal("IP_ADDRESS"))
//                    expect(parametersArr["uc704"]).to(equal("SNAME"))
//                    expect(parametersArr["uc702"]).to(equal("NEWSLETTER"))
                    //expect(parametersArr["oi"]).to(equal("ORDER_NUMBER"))
//                    expect(parametersArr["pu"]).to(equal("PAGE_URL"))
//                    expect(parametersArr["uc705"]).to(equal("PHONE"))
//                    expect(parametersArr["ba"]).to(equal("PRODUCT"))
//                    expect(parametersArr["co"]).to(equal("PRODUCT_COST"))
//                    expect(parametersArr["qn"]).to(equal("2"))
                    //expect(parametersArr["st"]).to(equal("conf"))
//                    expect(parametersArr["uc711"]).to(equal("STREET"))
//                    expect(parametersArr["uc712"]).to(equal("STREETNUMBER"))
                    //expect(parametersArr["ov"]).to(equal("ORDER_TOTAL"))
                    //expect(parametersArr["cb563"]).to(equal("VOUCHER_VALUE"))
//                    expect(parametersArr["uc710"]).to(equal("ZIP"))
                }
    }
    
    func testVariablesParameterScreen()
    {
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }

        
        doURLSendTestAction(){
            self.mainViewController.beginAppearanceTransition(true, animated: false)
            let tracker = WebtrekkTracking.trackerForAutotrackedViewController(self.mainViewController)

//          tracker.variables["ADVERTISEMENT"]="ADVERTISEMENT"
//          tracker.variables["ADVERTISEMENT_ACTION"]="ADVERTISEMENT_ACTION"
            tracker["BIRTHDAY"]="19761008"
//          tracker.variables["CITY"]="CITY"
//          tracker.variables["COUNTRY"]="COUNTRY"
            tracker["CURRENCYOver"]="CURRENCYOver"
            tracker["CUSTOMER_ID"]="CUSTOMER_ID"
            tracker["EMAIL"]="EMAIL"
            tracker["EMAIL_RID"]="EMAIL_RID"
//          tracker.variables["GNAME"]="GNAME"
            tracker["GENDER"]="1"
            tracker["INTERN_SEARCHOver"]="INTERN_SEARCHOver"
//          tracker["IP_ADDRESS"]="IP_ADDRESS"
//          tracker["SNAME"]="SNAME"
//          tracker["NEWSLETTER"]="NEWSLETTER"
            tracker["ORDER_NUMBER"]="ORDER_NUMBER"
//          tracker["PAGE_URL"]="PAGE_URL"
//          tracker["PHONE"]="PHONE"
            tracker["PRODUCT"]="PRODUCT"
            tracker["PRODUCT_COST"]="PRODUCT_COST"
            tracker["PRODUCT_COUNT"]="2"
            tracker["PRODUCT_STATUS"]="conf"
//          tracker["STREET"]="STREET"
//          tracker["STREETNUMBER"]="STREETNUMBER"
            tracker["ORDER_TOTAL"]="ORDER_TOTAL"
            tracker["VOUCHER_VALUE"]="VOUCHER_VALUE"
//          tracker["ZIP"]="ZIP"
            
            tracker.ecommerceProperties.products = [EcommerceProperties.Product(name: "productName1", categories: [11: "productCat11", 12: "productCat12"], price:"100", quantity: 1),
                EcommerceProperties.Product(name: "productName2", categories: [11: "productCat21", 12: "productCat22"], price:"200", quantity: 2)]
            tracker.ecommerceProperties.totalValue = "ORDER_TOTALCODE"

            self.mainViewController.endAppearanceTransition()
        }
        
        self.timeout = 10
        doURLSendTestCheck(){parametersArr in
//          expect(parametersArr["mc"]).to(equal("ADVERTISEMENT"))
//          expect(parametersArr["mca"]).to(equal("ADVERTISEMENT_ACTION"))
            expect(parametersArr["uc707"]).to(equal("19761008"))
//          expect(parametersArr["uc708"]).to(equal("CITY"))
//          expect(parametersArr["uc709"]).to(equal("COUNTRY"))
            expect(parametersArr["cr"]).to(equal("CURRENCYOver"))
            expect(parametersArr["cd"]).to(equal("CUSTOMER_ID"))
            expect(parametersArr["uc700"]).to(equal("EMAIL"))
            expect(parametersArr["uc701"]).to(equal("EMAIL_RID"))
//          expect(parametersArr["uc703"]).to(equal("GNAME"))
            expect(parametersArr["uc706"]).to(equal("1"))
            expect(parametersArr["is"]).to(equal("INTERN_SEARCHOver"))
//          expect(parametersArr["X_WT_IP"]).to(equal("IP_ADDRESS"))
//          expect(parametersArr["uc704"]).to(equal("SNAME"))
//          expect(parametersArr["uc702"]).to(equal("NEWSLETTER"))
            expect(parametersArr["oi"]).to(equal("ORDER_NUMBER"))
//          expect(parametersArr["pu"]).to(equal("PAGE_URL"))
//          expect(parametersArr["uc705"]).to(equal("PHONE"))
            expect(parametersArr["ba"]).to(equal("PRODUCT"))
            expect(parametersArr["co"]).to(equal("PRODUCT_COST"))
            expect(parametersArr["qn"]).to(equal("2"))
            expect(parametersArr["st"]).to(equal("conf"))
//          expect(parametersArr["uc711"]).to(equal("STREET"))
//          expect(parametersArr["uc712"]).to(equal("STREETNUMBER"))
            expect(parametersArr["ov"]).to(equal("ORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("VOUCHER_VALUE"))
//          expect(parametersArr["uc710"]).to(equal("ZIP"))
        }
    }

    // MARK: test several parameters track
    func testParameters(){
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }
        
        doURLSendTestAction(){
            self.mainViewController.beginAppearanceTransition(true, animated: false)
            let tracker = WebtrekkTracking.trackerForAutotrackedViewController(self.mainViewController)
            WebtrekkTracking.instance().pageURL = nil
            tracker["CURRENCYOver"] = "CURRENCY"
            tracker["CURRENCY"] = "GlobalIgnore"

            //uncomment after fix with default memberwise initializer is done.
            tracker.userProperties.birthday = UserProperties.Birthday(day: 11, month: 4, year: 1986)
            tracker.userProperties.city = "CITY"
            tracker.userProperties.country = "COUNTRY"
            tracker.userProperties.details = [10: "userCustomField10"]
            tracker.userProperties.emailAddress = "someaddress@domain.com"
            tracker.userProperties.emailReceiverId = "EMAIL_RID"
            tracker.userProperties.firstName = "GNAME"
            tracker.userProperties.gender = .female
            tracker.userProperties.id = "userID"
            tracker.userProperties.lastName = "SNAME"
            tracker.userProperties.newsletterSubscribed = false
            tracker.userProperties.phoneNumber = "123456789"
            tracker.userProperties.street = "STREET"
            tracker.userProperties.streetNumber = "123a"
            tracker.userProperties.zipCode = "10115"
            
            
            tracker.ecommerceProperties.currencyCode = "CURRENCYCodeIgnore"
            tracker.ecommerceProperties.details = [10 : "ecomeCustomField10"]
            tracker.ecommerceProperties.orderNumber = "ORDER_NUMBER"
            tracker.ecommerceProperties.products = [EcommerceProperties.Product(name: "productName1", categories: [11: "productCat11", 12: "productCat12"], price:"100", quantity: 1),
                EcommerceProperties.Product(name: "productName2", categories: [11: "productCat21", 12: "productCat22"], price:"200", quantity: 2)]
            tracker.ecommerceProperties.totalValue = "ORDER_TOTAL"
            tracker.ecommerceProperties.voucherValue = "VOUCHER_VALUE"
            tracker.ecommerceProperties.status = .viewed
            
            
            tracker.pageProperties.name = "pageNameNotauto"
            tracker.pageProperties.groups = [10: "pageCat10", 11: "pageCat11"]
            tracker.pageProperties.internalSearch = "InternalSearch"
            tracker.pageProperties.url = "http://www.webrekk.com"
            tracker.pageProperties.details = [30: "pageCustom30", 31: "pageCustom31"]
            
            tracker.advertisementProperties.id = "ADVERTISEMENT"
            tracker.advertisementProperties.action = "ADVERTISEMENT_ACTION"
            tracker.advertisementProperties.details = [10: "advertCustom10", 11: "advertCustom11"]
            
            tracker.sessionDetails = [10: "sessionCustom10", 11: "sessionCustom11"]
            
            self.mainViewController.endAppearanceTransition()
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("autoPageName"))
            expect(parametersArr["uc707"]).to(equal("19860411"))
            expect(parametersArr["uc708"]).to(equal("CITY"))
            expect(parametersArr["uc709"]).to(equal("COUNTRY"))
            expect(parametersArr["cr"]).to(equal("CURRENCY"))
            expect(parametersArr["cd"]).to(equal("userID"))
            expect(parametersArr["uc700"]).to(equal("someaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("EMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("GNAME"))
            expect(parametersArr["uc706"]).to(equal("2"))
            expect(parametersArr["is"]).to(equal("InternalSearch"))
            //expect(parametersArr["X_WT_IP"]).to(equal("IP_ADDRESS"))
            expect(parametersArr["uc704"]).to(equal("SNAME"))
            expect(parametersArr["uc702"]).to(equal("2"))
            expect(parametersArr["oi"]).to(equal("ORDER_NUMBER"))
            expect(parametersArr["pu"]).to(equal("http%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["uc705"]).to(equal("123456789"))
            expect(parametersArr["ba"]).to(equal("productName1;productName2"))
            expect(parametersArr["ca11"]).to(equal("productCat11;productCat21"))
            expect(parametersArr["ca12"]).to(equal("productCat12;productCat22"))
            expect(parametersArr["co"]).to(equal("100;200"))
            expect(parametersArr["qn"]).to(equal("1;2"))
            expect(parametersArr["st"]).to(equal("view"))
            expect(parametersArr["uc711"]).to(equal("STREET"))
            expect(parametersArr["uc712"]).to(equal("123a"))
            expect(parametersArr["ov"]).to(equal("ORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("VOUCHER_VALUE"))
            expect(parametersArr["uc710"]).to(equal("10115"))
            expect(parametersArr["uc10"]).to(equal("userCustomField10"))
            expect(parametersArr["cg10"]).to(equal("pageCat10"))
            expect(parametersArr["cg11"]).to(equal("pageCat11"))
            expect(parametersArr["is"]).to(equal("InternalSearch"))
            expect(parametersArr["pu"]).to(equal("http%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["cp30"]).to(equal("pageCustom30"))
            expect(parametersArr["cp31"]).to(equal("pageCustom31"))
            expect(parametersArr["mc"]).to(equal("ADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("ADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("advertCustom10"))
            expect(parametersArr["cc11"]).to(equal("advertCustom11"))
            expect(parametersArr["cs10"]).to(equal("sessionCustom10"))
            expect(parametersArr["cs11"]).to(equal("sessionCustom11"))
            
        }
        
        doURLSendTestAction(){
            let tracker = WebtrekkTracking.instance()
            
            tracker.global.userProperties.details = [3: "customUser3"]
            tracker.global.sessionDetails = [1: "shouldBeIgnored"]
            tracker.global.pageProperties.internalSearch = "ShouldBeIgnoredIS"
            tracker.global.advertisementProperties.details = [23: "customAdv23"]
            
            tracker["CURRENCY"] = "CURRENCYGlobalParIgnore"
            tracker["INTERN_SEARCH"] = "InternalSearch"
            
            tracker.pageURL = nil
            let pagePropertiesL = PageProperties(
                name: "pageNameNotauto",
                details: [30: "pageCustom30", 31: "pageCustom31"],
                groups: [10: "pageCat10", 11: "pageCat11"],
                internalSearch: nil,
                url: "http://www.webrekk.com")
            let userPropertiesL = UserProperties(
                birthday: UserProperties.Birthday(day: 11, month: 4, year: 1986),
                city: "CITY",
                country: "COUNTRY",
                details: [10: "userCustomField10"],
                emailAddress: "someaddress@domain.com",
                emailReceiverId: "EMAIL_RID",
                firstName: "GNAME",
                gender: .female,
                id: "userID",
                lastName: "SNAME",
                newsletterSubscribed: false,
                phoneNumber: "123456789",
                street: "STREET",
                streetNumber: "123a",
                zipCode: "10115")
            
            let advPropertiesL = AdvertisementProperties(
                id: "ADVERTISEMENT",
                action: "ADVERTISEMENT_ACTION",
                details: [10: "advertCustom10", 11: "advertCustom11"])
            
            let ecomPropertiesL = EcommerceProperties(
                currencyCode: "CURRENCY",
                details: [10 : "ecomeCustomField10"],
                orderNumber: "ORDER_NUMBER",
                products: [EcommerceProperties.Product(name: "productName1", categories: [11: "productCat11", 12: "productCat12"], price:"100", quantity: 1),
                    EcommerceProperties.Product(name: "productName2", categories: [11: "productCat21", 12: "productCat22"], price:"200", quantity: 2)],
                status: .viewed,
                totalValue: "ORDER_TOTAL",
                voucherValue: "VOUCHER_VALUE")
 
            
            let pageEvent = PageViewEvent(
                pageProperties: pagePropertiesL,
                advertisementProperties: advPropertiesL,
                ecommerceProperties: ecomPropertiesL,
                ipAddress: "IP_ADDRESS",
                sessionDetails: [10: "sessionCustom10", 11: "sessionCustom11"],
                userProperties: userPropertiesL)
            
            tracker.trackPageView(pageEvent)
        }
        
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("pageNameNotauto"))
            expect(parametersArr["uc707"]).to(equal("19860411"))
            expect(parametersArr["uc708"]).to(equal("CITY"))
            expect(parametersArr["uc709"]).to(equal("COUNTRY"))
            expect(parametersArr["cr"]).to(equal("CURRENCY"))
            expect(parametersArr["cd"]).to(equal("userID"))
            expect(parametersArr["uc700"]).to(equal("someaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("EMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("GNAME"))
            expect(parametersArr["uc706"]).to(equal("2"))
            expect(parametersArr["is"]).to(equal("InternalSearch"))
            //expect(parametersArr["X_WT_IP"]).to(equal("IP_ADDRESS"))
            expect(parametersArr["uc704"]).to(equal("SNAME"))
            expect(parametersArr["uc702"]).to(equal("2"))
            expect(parametersArr["oi"]).to(equal("ORDER_NUMBER"))
            expect(parametersArr["pu"]).to(equal("http%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["uc705"]).to(equal("123456789"))
            expect(parametersArr["ba"]).to(equal("productName1;productName2"))
            expect(parametersArr["ca11"]).to(equal("productCat11;productCat21"))
            expect(parametersArr["ca12"]).to(equal("productCat12;productCat22"))
            expect(parametersArr["co"]).to(equal("100;200"))
            expect(parametersArr["qn"]).to(equal("1;2"))
            expect(parametersArr["st"]).to(equal("view"))
            expect(parametersArr["oi"]).to(equal("ORDER_NUMBER"))
            expect(parametersArr["uc711"]).to(equal("STREET"))
            expect(parametersArr["uc712"]).to(equal("123a"))
            expect(parametersArr["ov"]).to(equal("ORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("VOUCHER_VALUE"))
            expect(parametersArr["uc710"]).to(equal("10115"))
            expect(parametersArr["uc10"]).to(equal("userCustomField10"))
            expect(parametersArr["cg10"]).to(equal("pageCat10"))
            expect(parametersArr["cg11"]).to(equal("pageCat11"))
            expect(parametersArr["is"]).to(equal("InternalSearch"))
            expect(parametersArr["pu"]).to(equal("http%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["cp30"]).to(equal("pageCustom30"))
            expect(parametersArr["cp31"]).to(equal("pageCustom31"))
            expect(parametersArr["mc"]).to(equal("ADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("ADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("advertCustom10"))
            expect(parametersArr["cc11"]).to(equal("advertCustom11"))
            expect(parametersArr["cc23"]).to(equal("customAdv23"))
            expect(parametersArr["cs10"]).to(equal("sessionCustom10"))
            expect(parametersArr["cs1"]).to(equal("test_sessionparam1"))
            expect(parametersArr["uc3"]).to(equal("customUser3"))
            
        }
        
    }
}
