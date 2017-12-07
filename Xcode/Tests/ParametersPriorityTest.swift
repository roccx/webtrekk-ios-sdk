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
//  Copyright © 2016 Webtrekk. All rights reserved.
//

import XCTest
import Nimble
import Webtrekk

class ParametersPriorityTest: WTBaseTestNew {
    
    override func getConfigName() -> String?{
            return "webtrekk_prioritization_test"
    }
    
    //do just global parameter test
    func testGlobalParameter(){
        doURLSendTestAction {
            let tracker = WebtrekkTracking.instance()
            setupGlobal(global: tracker.global)
            
            tracker.trackPageView("trackPageName")
        }
        
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("trackPageName"))
            expect(parametersArr["uc707"]).to(equal("19860411"))
            expect(parametersArr["uc708"]).to(equal("GLCITY"))
            expect(parametersArr["uc709"]).to(equal("GLCOUNTRY"))
            expect(parametersArr["cr"]).to(equal("GLCURRENCY"))
            expect(parametersArr["cd"]).to(equal("GLuserID"))
            expect(parametersArr["uc700"]).to(equal("GLsomeaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("GLEMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("GLNAME"))
            expect(parametersArr["uc706"]).to(equal("2"))
            expect(parametersArr["is"]).to(equal("GLInternalSearch"))
            expect(parametersArr["X-WT-IP"]).to(equal("127.0.0.1"))
            expect(parametersArr["uc704"]).to(equal("GLSNAME"))
            expect(parametersArr["uc702"]).to(equal("2"))
            expect(parametersArr["oi"]).to(equal("GLORDER_NUMBER"))
            expect(parametersArr["uc705"]).to(equal("123456789"))
            expect(parametersArr["ba"]).to(equal("GLproductName1;GLproductName2"))
            expect(parametersArr["ca11"]).to(equal("GLproductCat11;GLproductCat21"))
            expect(parametersArr["ca12"]).to(equal("GLproductCat12;GLproductCat22"))
            expect(parametersArr["co"]).to(equal("100;200"))
            expect(parametersArr["qn"]).to(equal("1;2"))
            expect(parametersArr["st"]).to(equal("view"))
            expect(parametersArr["uc711"]).to(equal("GLSTREET"))
            expect(parametersArr["uc712"]).to(equal("GL123a"))
            expect(parametersArr["ov"]).to(equal("GLORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("GLVOUCHER_VALUE"))
            expect(parametersArr["uc710"]).to(equal("10115"))
            expect(parametersArr["uc10"]).to(equal("GLuserCustomField10"))
            expect(parametersArr["uc11"]).to(equal("GLuserCustomField11"))
            expect(parametersArr["cg10"]).to(equal("GLpageCat10"))
            expect(parametersArr["cg11"]).to(equal("GLpageCat11"))
            expect(parametersArr["is"]).to(equal("GLInternalSearch"))
            expect(parametersArr["pu"]).to(equal("GLhttp%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["cp30"]).to(equal("GLpageCustom30"))
            expect(parametersArr["cp31"]).to(equal("GLpageCustom31"))
            expect(parametersArr["mc"]).to(equal("GLADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("GLADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("GLadvertCustom10"))
            expect(parametersArr["cc11"]).to(equal("GLadvertCustom11"))
            expect(parametersArr["cs10"]).to(equal("GLsessionCustom10"))
            expect(parametersArr["cs11"]).to(equal("GLsessionCustom11"))
            expect(parametersArr["cb10"]).to(equal("GLecomeCustomField10"))
            expect(parametersArr["cb11"]).to(equal("GLecomeCustomField11"))
            
            //check that autoParameters overrided some
            expect(parametersArr["cs804"]).notTo(equal("GLsessionCustom804"))
            expect(parametersArr["cs809"]).notTo(equal("GLsessionCustom809"))
            expect(parametersArr["cp784"]).notTo(equal("GLpageCustom784"))
        }
    }
    
    //override it with GlobalConfParameter
    func testGlobalConfParameter(){
        doURLSendTestAction {
            let tracker = WebtrekkTracking.instance()
            
            setupGlobal(global: tracker.global)
            setupGlobalConf(tracker: tracker)
            
            tracker.trackPageView("trackPageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("trackPageName"))
            expect(parametersArr["uc707"]).to(equal("19860412"))
            expect(parametersArr["uc708"]).to(equal("GLConfCITY"))
            expect(parametersArr["uc709"]).to(equal("GLConfCOUNTRY"))
            expect(parametersArr["cr"]).to(equal("GLConfCURRENCY"))
            expect(parametersArr["cd"]).to(equal("GLConfuserID"))
            expect(parametersArr["uc700"]).to(equal("GLConfsomeaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("GLConfEMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("GLConfNAME"))
            expect(parametersArr["uc706"]).to(equal("1"))
            expect(parametersArr["pu"]).to(equal("GLConfhttp%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["is"]).to(equal("GLConfInternalSearch"))
            expect(parametersArr["X-WT-IP"]).to(equal("127.0.0.3"))
            expect(parametersArr["uc704"]).to(equal("GLConfSNAME"))
            expect(parametersArr["uc702"]).to(equal("2"))
            expect(parametersArr["uc705"]).to(equal("1123456789"))
            expect(parametersArr["uc711"]).to(equal("GLConfSTREETKey"))
            expect(parametersArr["uc712"]).to(equal("GLConf123a"))
            expect(parametersArr["uc710"]).to(equal("20115"))
            
            expect(parametersArr["ba"]).to(equal("GLConfProductName"))
            expect(parametersArr["ca11"]).to(equal("GLConfproductCat11"))
            expect(parametersArr["ca12"]).to(equal("GLproductCat12"))
            expect(parametersArr["co"]).to(equal("300"))
            expect(parametersArr["qn"]).to(equal("5"))
            expect(parametersArr["st"]).to(equal("add"))
            expect(parametersArr["ov"]).to(equal("GLConfORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("GLConfVOUCHER_VALUE"))
            expect(parametersArr["oi"]).to(equal("GLConfORDER_NUMBER"))
            
            expect(parametersArr["cp30"]).to(equal("GLConfpageCustom30"))
            expect(parametersArr["cp31"]).to(equal("GLpageCustom31"))
            expect(parametersArr["cp3"]).to(equal("PageGlobalConfStaticValue"))
            
            expect(parametersArr["cg10"]).to(equal("GLConfpageCat10"))
            expect(parametersArr["cg11"]).to(equal("GLpageCat11"))
            expect(parametersArr["cg3"]).to(equal("PageCatGlobalConfStaticValue"))
            
            expect(parametersArr["cs10"]).to(equal("GLConfsessionCustom10"))
            expect(parametersArr["cs11"]).to(equal("GLsessionCustom11"))
            expect(parametersArr["cs3"]).to(equal("SessionGlobalConfStaticValue"))
            
            expect(parametersArr["cb10"]).to(equal("GLConfecomeCustomField10"))
            expect(parametersArr["cb11"]).to(equal("GLecomeCustomField11"))
            expect(parametersArr["cb3"]).to(equal("EconGlobalConfStaticValue"))

            expect(parametersArr["uc10"]).to(equal("GLConfuserCustomField10"))
            expect(parametersArr["uc11"]).to(equal("GLuserCustomField11"))
            expect(parametersArr["uc3"]).to(equal("UserGlobalConfStaticValue"))
            
            expect(parametersArr["mc"]).to(equal("GLConfADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("GLConfADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("GLConfadvertCustom10"))
            expect(parametersArr["cc11"]).to(equal("GLadvertCustom11"))
            expect(parametersArr["cc3"]).to(equal("AdvGlobalConfStaticValue"))
            
            //auto tracking parameters check
            expect(parametersArr["cp784"]).to(equal("RequestSizeConf"))
            expect(parametersArr["cs804"]).to(equal("VersionOverGlobalConf"))
            expect(parametersArr["cs809"]).to(equal("AdvertizingIDGlobalConf"))
           
        }
    }
    
    //check that code is overrided
    func testParameterFromCode(){
        doURLSendTestAction {
            let tracker = WebtrekkTracking.instance()
            
            setupGlobal(global: tracker.global)
            setupGlobalConf(tracker: tracker)
            
            tracker.trackPageView(setupCodeConf())
        }
        
        doURLSendTestCheck(){parametersArr in
            
            expect(parametersArr["p"]).to(contain("CodepageNameNotauto"))
            expect(parametersArr["uc707"]).to(equal("19860412"))
            expect(parametersArr["uc708"]).to(equal("CodeCITY"))
            expect(parametersArr["uc709"]).to(equal("CodeCOUNTRY"))
            expect(parametersArr["cr"]).to(equal("CodeCURRENCY"))
            expect(parametersArr["cd"]).to(equal("CodeuserID"))
            expect(parametersArr["uc700"]).to(equal("Codesomeaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("CodeEMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("CodeGNAME"))
            expect(parametersArr["uc706"]).to(equal("3"))
            expect(parametersArr["is"]).to(equal("CodeInternalSearch"))
            expect(parametersArr["X-WT-IP"]).to(equal("127.0.0.2"))
            expect(parametersArr["uc704"]).to(equal("CodeSNAME"))
            expect(parametersArr["uc702"]).to(equal("1"))
            expect(parametersArr["oi"]).to(equal("CodeORDER_NUMBER"))
            expect(parametersArr["uc705"]).to(equal("1234567891"))
            expect(parametersArr["ba"]).to(equal("CodeproductName1;CodeproductName2"))
            expect(parametersArr["ca11"]).to(equal("CodeproductCat11;CodeproductCat21"))
            expect(parametersArr["ca12"]).to(equal("CodeproductCat12;CodeproductCat22"))
            expect(parametersArr["co"]).to(equal("300;400"))
            expect(parametersArr["qn"]).to(equal("3;4"))
            expect(parametersArr["st"]).to(equal("conf"))
            expect(parametersArr["uc711"]).to(equal("CodeSTREET"))
            expect(parametersArr["uc712"]).to(equal("Code123a"))
            expect(parametersArr["ov"]).to(equal("CodeORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("CodeVOUCHER_VALUE"))
            expect(parametersArr["uc710"]).to(equal("10116"))
            expect(parametersArr["uc10"]).to(equal("CodeuserCustomField10"))
            expect(parametersArr["uc11"]).to(equal("GLuserCustomField11"))
            expect(parametersArr["cg10"]).to(equal("CodepageCat10"))
            expect(parametersArr["cg11"]).to(equal("GLpageCat11"))
            expect(parametersArr["is"]).to(equal("CodeInternalSearch"))
            expect(parametersArr["pu"]).to(equal("Codehttp%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["cp30"]).to(equal("CodepageCustom30"))
            expect(parametersArr["cp31"]).to(equal("GLpageCustom31"))
            expect(parametersArr["mc"]).to(equal("CodeADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("CodeADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("CodeadvertCustom10"))
            expect(parametersArr["cc11"]).to(equal("GLadvertCustom11"))
            expect(parametersArr["cs10"]).to(equal("CodesessionCustom10"))
            expect(parametersArr["cs11"]).to(equal("GLsessionCustom11"))
            expect(parametersArr["cb10"]).to(equal("CodeecomeCustomField10"))
            expect(parametersArr["cb11"]).to(equal("GLecomeCustomField11"))
            
            //auto tracking parameters check
            expect(parametersArr["cp784"]).to(equal("RequestSizeConf"))
            expect(parametersArr["cs804"]).to(equal("VersionOverGlobalConf"))
            expect(parametersArr["cs809"]).to(equal("AdvertizingIDGlobalConf"))
            
        }
    }
    
    //check that screen conf is overrided
    func testParametersFromScreenConf(){
        let mainViewController = ViewController()
        
        doURLSendTestAction {
            mainViewController.beginAppearanceTransition(true, animated: false)
            let tracker = WebtrekkTracking.instance()
            
            setupGlobal(global: tracker.global)
            setupGlobalConf(tracker: tracker)
            addScreenConf(tracker: tracker)
            
            mainViewController.endAppearanceTransition()
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("autoPageName"))
            expect(parametersArr["uc707"]).to(equal("19860413"))
            expect(parametersArr["uc708"]).to(equal("SCConfCITY"))
            expect(parametersArr["uc709"]).to(equal("SCConfCOUNTRY"))
            expect(parametersArr["cr"]).to(equal("SCConfCURRENCY"))
            expect(parametersArr["cd"]).to(equal("SCConfuserID"))
            expect(parametersArr["uc700"]).to(equal("SCConfsomeaddress%40domain.com"))
            expect(parametersArr["uc701"]).to(equal("SCConfEMAIL_RID"))
            expect(parametersArr["uc703"]).to(equal("SCConfNAME"))
            expect(parametersArr["uc706"]).to(equal("2"))
            expect(parametersArr["pu"]).to(equal("SCConfhttp%3A%2F%2Fwww.webrekk.com"))
            expect(parametersArr["is"]).to(equal("SCConfInternalSearch"))
            expect(parametersArr["X-WT-IP"]).to(equal("127.0.0.4"))
            expect(parametersArr["uc704"]).to(equal("SCConfSNAME"))
            expect(parametersArr["uc702"]).to(equal("2"))
            expect(parametersArr["uc705"]).to(equal("2123456789"))
            expect(parametersArr["uc711"]).to(equal("SCConfSTREETKey"))
            expect(parametersArr["uc712"]).to(equal("SCConf123a"))
            expect(parametersArr["uc710"]).to(equal("30115"))
            
            expect(parametersArr["ba"]).to(equal("SCConfProductName"))
            expect(parametersArr["ca11"]).to(equal("SCConfproductCat11"))
            expect(parametersArr["ca12"]).to(equal("GLproductCat12"))
            expect(parametersArr["ca3"]).to(equal("PrCatScreenConfStaticValue"))
            expect(parametersArr["co"]).to(equal("600"))
            expect(parametersArr["qn"]).to(equal("6"))
            expect(parametersArr["st"]).to(equal("view"))
            expect(parametersArr["ov"]).to(equal("SCConfORDER_TOTAL"))
            expect(parametersArr["cb563"]).to(equal("SCConfVOUCHER_VALUE"))
            expect(parametersArr["oi"]).to(equal("SCConfORDER_NUMBER"))
            
            expect(parametersArr["cp30"]).to(equal("SCConfpageCustom30"))
            expect(parametersArr["cp31"]).to(equal("GLpageCustom31"))
            expect(parametersArr["cp3"]).to(equal("PageScreenConfStaticValue"))
            
            expect(parametersArr["cg10"]).to(equal("SCConfpageCat10"))
            expect(parametersArr["cg11"]).to(equal("GLpageCat11"))
            expect(parametersArr["cg3"]).to(equal("PageCatScreenConfStaticValue"))
            
            expect(parametersArr["cs10"]).to(equal("SCConfsessionCustom10"))
            expect(parametersArr["cs11"]).to(equal("GLsessionCustom11"))
            expect(parametersArr["cs3"]).to(equal("SessionScreenConfStaticValue"))
            
            expect(parametersArr["cb10"]).to(equal("SCConfecomeCustomField10"))
            expect(parametersArr["cb11"]).to(equal("GLecomeCustomField11"))
            expect(parametersArr["cb3"]).to(equal("EconScreenConfStaticValue"))
            
            expect(parametersArr["uc10"]).to(equal("SCConfuserCustomField10"))
            expect(parametersArr["uc11"]).to(equal("GLuserCustomField11"))
            expect(parametersArr["uc3"]).to(equal("UserScreenConfStaticValue"))
            
            expect(parametersArr["mc"]).to(equal("SCConfADVERTISEMENT"))
            expect(parametersArr["mca"]).to(equal("SCConfADVERTISEMENT_ACTION"))
            expect(parametersArr["cc10"]).to(equal("SCConfadvertCustom10"))
            expect(parametersArr["cc11"]).to(equal("GLadvertCustom11"))
            expect(parametersArr["cc3"]).to(equal("AdvScreenConfStaticValue"))
        }
    }
    
    private func addScreenConf(tracker: Tracker){
        
        tracker["SCBIRTHDAYKey"] = "19860413"
        tracker["SCCITYKey"] = "SCConfCITY"
        tracker["SCCOUNTRYKey"] = "SCConfCOUNTRY"
        tracker["SCCURRENCYKey"] = "SCConfCURRENCY"
        tracker["SCUSERIDKey"] = "SCConfuserID"
        tracker["SCEMAILKey"] = "SCConfsomeaddress@domain.com"
        tracker["SCEMAIL_RIDKey"] = "SCConfEMAIL_RID"
        tracker["SCNAMEKey"] = "SCConfNAME"
        tracker["SCGENDERKey"] = "2"
        tracker["SCINTERN_SEARCHKey"] = "SCConfInternalSearch"
        tracker["SCIP_ADDRESSKey"] = "127.0.0.4"
        tracker["SCSNAMEKey"] = "SCConfSNAME"
        tracker["SCNEWSLETTERKey"] = "2"
        tracker["SCPAGE_URLKey"] = "SCConfhttp://www.webrekk.com"
        tracker["SCPHONEKey"] = "2123456789"
        tracker["SCSTREETKey"] = "SCConfSTREETKey"
        tracker["SCSTREETNUMBERKey"] = "SCConf123a"
        tracker["SCZIPKey"] = "30115"
        tracker["SCPRODUCTKey"] = "SCConfProductName"
        tracker["SCPRODUCT_COSTKey"] = "600"
        tracker["SCPRODUCT_COUNTKey"] = "6"
        tracker["SCPRODUCT_STATUSKey"] = "view"
        tracker["SCORDER_NUMBERKey"] = "SCConfORDER_NUMBER"
        tracker["SCORDER_TOTALKey"] = "SCConfORDER_TOTAL"
        tracker["SCVOUCHER_VALUEKey"] = "SCConfVOUCHER_VALUE"
        tracker["KeyPageScreenConfOver"] = "SCConfpageCustom30"
        tracker["KeyPageCatScreenConfOver"] = "SCConfpageCat10"
        tracker["KeySessionScreenConfOver"] = "SCConfsessionCustom10"
        tracker["KeyEcomScreenConfOver"] = "SCConfecomeCustomField10"
        tracker["KeyUserScreenConfOver"] = "SCConfuserCustomField10"
        tracker["SCADVERTISEMENTKey"] = "SCConfADVERTISEMENT"
        tracker["SCADVERTISEMENT_ACTIONKey"] = "SCConfADVERTISEMENT_ACTION"
        tracker["KeyAdvScreenConfOver"] = "SCConfadvertCustom10"
        tracker["KeyPrCatScreenConfOver"] = "SCConfproductCat11"
    }
    
    //set keys from code
    private func setupCodeConf() -> PageViewEvent{
        
        let userProperties = UserProperties(
            birthday: UserProperties.Birthday(day: 12, month: 4, year: 1986),
            city: "CodeCITY",
            country: "CodeCOUNTRY",
            details: [10: "CodeuserCustomField10"],
            emailAddress: "Codesomeaddress@domain.com",
            emailReceiverId: "CodeEMAIL_RID",
            firstName: "CodeGNAME",
            gender: .unknown,
            id: "CodeuserID",
            lastName: "CodeSNAME",
            newsletterSubscribed: true,
            phoneNumber: "1234567891",
            street: "CodeSTREET",
            streetNumber: "Code123a",
            zipCode: "10116")
        
        
        // TODO Product merge
        let ecomProperties = EcommerceProperties(
            currencyCode: "CodeCURRENCY",
            details: [10 : "CodeecomeCustomField10"],
            orderNumber: "CodeORDER_NUMBER",
            products: [EcommerceProperties.Product(name: "CodeproductName1", categories: [11: "CodeproductCat11", 12: "CodeproductCat12"], price:"300", quantity: 3),
                       EcommerceProperties.Product(name: "CodeproductName2", categories: [11: "CodeproductCat21", 12: "CodeproductCat22"], price:"400", quantity: 4)],
            status: .purchased,
            totalValue: "CodeORDER_TOTAL",
            voucherValue: "CodeVOUCHER_VALUE")
        
        let pageProperties = PageProperties(
            name: "CodepageNameNotauto",
            details: [30: "CodepageCustom30"],
            groups: [10: "CodepageCat10"],
            internalSearch: "CodeInternalSearch",
            url: "Codehttp://www.webrekk.com")

        
        let advProperties = AdvertisementProperties(
            id: "CodeADVERTISEMENT",
            action: "CodeADVERTISEMENT_ACTION",
            details: [10: "CodeadvertCustom10"])

        let pageEvent = PageViewEvent(
            pageProperties: pageProperties,
            advertisementProperties: advProperties,
            ecommerceProperties: ecomProperties,
            ipAddress: "127.0.0.2",
            sessionDetails: [10: "CodesessionCustom10"],
            userProperties: userProperties)
        
        return pageEvent
    }
    
    
    //set keys for global conf settings
    private func setupGlobalConf(tracker: Tracker){
        
        tracker["GLBIRTHDAYKey"] = "19860412"
        tracker["GLCITYKey"] = "GLConfCITY"
        tracker["GLCOUNTRYKey"] = "GLConfCOUNTRY"
        tracker["GLCURRENCYKey"] = "GLConfCURRENCY"
        tracker["GLUSERIDKey"] = "GLConfuserID"
        tracker["GLEMAILKey"] = "GLConfsomeaddress@domain.com"
        tracker["GLEMAIL_RIDKey"] = "GLConfEMAIL_RID"
        tracker["GLNAMEKey"] = "GLConfNAME"
        tracker["GLGENDERKey"] = "1"
        tracker["GLINTERN_SEARCHKey"] = "GLConfInternalSearch"
        tracker["GLIP_ADDRESSKey"] = "127.0.0.3"
        tracker["GLSNAMEKey"] = "GLConfSNAME"
        tracker["GLNEWSLETTERKey"] = "0"
        tracker["GLPAGE_URLKey"] = "GLConfhttp://www.webrekk.com"
        tracker["GLPHONEKey"] = "1123456789"
        tracker["GLSTREETKey"] = "GLConfSTREETKey"
        tracker["GLSTREETNUMBERKey"] = "GLConf123a"
        tracker["GLZIPKey"] = "20115"
        tracker["GLPRODUCTKey"] = "GLConfProductName"
        tracker["GLPRODUCT_COSTKey"] = "300"
        tracker["GLPRODUCT_COUNTKey"] = "5"
        tracker["GLPRODUCT_STATUSKey"] = "add"
        tracker["GLORDER_NUMBERKey"] = "GLConfORDER_NUMBER"
        tracker["GLORDER_TOTALKey"] = "GLConfORDER_TOTAL"
        tracker["GLVOUCHER_VALUEKey"] = "GLConfVOUCHER_VALUE"
        tracker["KeyPageGlobalConfOver"] = "GLConfpageCustom30"
        tracker["KeyPageCatGlobalConfOver"] = "GLConfpageCat10"
        tracker["KeySessionGlobalConfOver"] = "GLConfsessionCustom10"
        tracker["KeyEcomGlobalConfOver"] = "GLConfecomeCustomField10"
        tracker["KeyUserGlobalConfOver"] = "GLConfuserCustomField10"
        tracker["GLADVERTISEMENTKey"] = "GLConfADVERTISEMENT"
        tracker["GLADVERTISEMENT_ACTIONKey"] = "GLConfADVERTISEMENT_ACTION"
        tracker["KeyAdvGlobalConfOver"] = "GLConfadvertCustom10"
        tracker["KeyPrCatGlobalConfOver"] = "GLConfproductCat11"
        
        //auto tracking parameters setup
        tracker["KeyRequestSizeConf"] = "RequestSizeConf"
        tracker["KeyVersionOverGlobalConf"] = "VersionOverGlobalConf"
        tracker["KeyAdvertizingIDGlobalConf"] = "AdvertizingIDGlobalConf"
        
    }
    
    // set global code parameters
    private func setupGlobal(global: GlobalProperties){
        
        global.userProperties.birthday = UserProperties.Birthday(day: 11, month: 4, year: 1986)
        global.userProperties.city = "GLCITY"
        global.userProperties.country = "GLCOUNTRY"
        global.userProperties.details = [10: "GLuserCustomField10", 11: "GLuserCustomField11"]
        global.userProperties.emailAddress = "GLsomeaddress@domain.com"
        global.userProperties.emailReceiverId = "GLEMAIL_RID"
        global.userProperties.firstName = "GLNAME"
        global.userProperties.gender = .female
        global.userProperties.id = "GLuserID"
        global.userProperties.lastName = "GLSNAME"
        global.userProperties.newsletterSubscribed = false
        global.userProperties.phoneNumber = "123456789"
        global.userProperties.street = "GLSTREET"
        global.userProperties.streetNumber = "GL123a"
        global.userProperties.zipCode = "10115"
        
        
        global.ecommerceProperties.currencyCode = "GLCURRENCY"
        global.ecommerceProperties.details = [10 : "GLecomeCustomField10", 11 : "GLecomeCustomField11"]
        global.ecommerceProperties.orderNumber = "GLORDER_NUMBER"
        global.ecommerceProperties.products = [EcommerceProperties.Product(name: "GLproductName1", categories: [11: "GLproductCat11", 12: "GLproductCat12"], price:"100", quantity: 1),
                                               EcommerceProperties.Product(name: "GLproductName2", categories: [11: "GLproductCat21", 12: "GLproductCat22"], price:"200", quantity: 2)]
        global.ecommerceProperties.totalValue = "GLORDER_TOTAL"
        global.ecommerceProperties.voucherValue = "GLVOUCHER_VALUE"
        global.ecommerceProperties.status = .viewed
        
        
        global.pageProperties.name = "GLpageNameNotauto"
        global.pageProperties.groups = [10: "GLpageCat10", 11: "GLpageCat11"]
        global.pageProperties.internalSearch = "GLInternalSearch"
        global.pageProperties.url = "GLhttp://www.webrekk.com"
        global.pageProperties.details = [30: "GLpageCustom30", 31: "GLpageCustom31", 784: "GLpageCustom784"]
        
        global.advertisementProperties.id = "GLADVERTISEMENT"
        global.advertisementProperties.action = "GLADVERTISEMENT_ACTION"
        global.advertisementProperties.details = [10: "GLadvertCustom10", 11: "GLadvertCustom11"]
        
        global.ipAddress = "127.0.0.1"
        
        global.sessionDetails = [10: "GLsessionCustom10", 11: "GLsessionCustom11", 804: "GLsessionCustom804", 809: "GLsessionCustom809"]
    }
}
