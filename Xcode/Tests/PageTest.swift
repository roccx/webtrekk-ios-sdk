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
@testable import Webtrekk


class PageTest: WTBaseTestNew {
    
    var mainViewController: ViewController!
    
    func testKeyValue(){
        doURLSendTestAction(){
            let defTracker = WebtrekkTracking.instance()
            defTracker.global.variables["Key1"] = "value1"
            defTracker.global.variables["Key2"] = "value2"
            defTracker.global.variables["KeyOver1"] = "overValue1"
            defTracker.trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            print("key value print for keyValueTestSimple______________")
            for (key, value) in parametersArr{
                print(key+"="+value)
            }
            expect(parametersArr["cp1"]).to(equal("value1"))
            expect(parametersArr["cp2"]).to(equal("value2"))
            expect(parametersArr["cb2"]).to(equal("value2"))
            expect(parametersArr["cc2"]).to(equal("value2"))
            expect(parametersArr["cs2"]).to(equal("value2"))
            expect(parametersArr["ca2"]).to(equal("value2"))
            expect(parametersArr["cg2"]).to(equal("value2"))
            expect(parametersArr["uc2"]).to(equal("value2"))
            
            expect(parametersArr["cp20"]).to(equal("test_pageparam2"))
            expect(parametersArr["cb1"]).to(equal("test_ecomparam1"))
            expect(parametersArr["cc1"]).to(equal("test_adparam1"))
            expect(parametersArr["cs1"]).to(equal("test_sessionparam1"))
            expect(parametersArr["ca1"]).to(equal("test_productcategory1"))
            expect(parametersArr["cg1"]).to(equal("test_pagecategory1"))
            expect(parametersArr["uc1"]).to(equal("test_usercategory1"))
        }
        
        
        doURLSendTestAction(){
                WebtrekkTracking.instance().trackPageView(PageProperties(name: "PageName", details: [20: "cp20Override"]))
        }

        doURLSendTestCheck(){parametersArr in
            print("key value print for keyValueTestSimple______________")
            for (key, value) in parametersArr{
                print(key+"="+value)
            }
            expect(parametersArr["cp1"]).to(equal("value1"))
            expect(parametersArr["cp2"]).to(equal("value2"))
            expect(parametersArr["cb2"]).to(equal("value2"))
            expect(parametersArr["cc2"]).to(equal("value2"))
            expect(parametersArr["cs2"]).to(equal("value2"))
            expect(parametersArr["ca2"]).to(equal("value2"))
            expect(parametersArr["cg2"]).to(equal("value2"))
            expect(parametersArr["uc2"]).to(equal("value2"))
            
            expect(parametersArr["cp20"]).to(equal("cp20Override"))
            expect(parametersArr["cb1"]).to(equal("test_ecomparam1"))
            expect(parametersArr["cc1"]).to(equal("test_adparam1"))
            expect(parametersArr["cs1"]).to(equal("test_sessionparam1"))
            expect(parametersArr["ca1"]).to(equal("test_productcategory1"))
            expect(parametersArr["cg1"]).to(equal("test_pagecategory1"))
            expect(parametersArr["uc1"]).to(equal("test_usercategory1"))
        }
    }
    
    func testCoding(){
        
        var allAllowedSymbols = CharacterSet.urlQueryAllowed
        
        
        let coddedSymbols = "+=\"',/?:@&#$"
        
        coddedSymbols.forEach { (ch) in
            allAllowedSymbols.remove(ch.unicodeScalars.first!)
        }

        var allASCIISympbols1 = ""
        var allASCIISympbols2 = ""

        for i in 0...127 {
            allASCIISympbols1 = allASCIISympbols1 + String(UnicodeScalar(i)!)
        }
        
        for i in 128...255{
            allASCIISympbols2 = allASCIISympbols2 + String(UnicodeScalar(i)!)
        }

        let codedASCIISymbols1 = allASCIISympbols1.addingPercentEncoding(withAllowedCharacters: allAllowedSymbols)
        let codedASCIISymbols2 = allASCIISympbols2.addingPercentEncoding(withAllowedCharacters: allAllowedSymbols)

        
        
        doURLSendTestAction(){
            let defTracker = WebtrekkTracking.instance()
            defTracker.global.variables["Key1"] = allASCIISympbols1
            defTracker.global.variables["Key2"] = allASCIISympbols2
            defTracker.trackPageView("page,Name")
        }
        
        doURLSendTestCheck(){parametersArr in
            print("key value print for keyValueTestSimple______________")
            for (key, value) in parametersArr{
                print(key+"="+value)
            }
            expect(parametersArr["cp1"]).to(equal(codedASCIISymbols1))
            expect(parametersArr["cp2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["cb2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["cc2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["cs2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["ca2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["cg2"]).to(equal(codedASCIISymbols2))
            expect(parametersArr["uc2"]).to(equal(codedASCIISymbols2))
            let pPar = parametersArr["p"] ?? ""
            let comaChar : [Character] = pPar.filter{ $0 == "," }

            expect(pPar.split(separator: ",").count).to(equal(10))
            expect(comaChar.count).to(equal(9))
            expect(pPar).to(contain("page%2CName"))
        }

    }
    
    func testUserAgent(){
        doURLSendTestAction(){
            let defTracker = WebtrekkTracking.instance()
            defTracker.trackPageView("pageName")
        }
        
        
        let operatingSystemName: String = {
            #if os(iOS)
                return "iOS"
            #elseif os(watchOS)
                return "watchOS"
            #elseif os(tvOS)
                return "tvOS"
            #elseif os(OSX)
                return "macOS"
            #endif
        }()

        let modelNumber: String = {
            #if os(iOS)
                return "iPhone"
            #else
                return "x86_64"
            #endif
        }()

        
        
        let version = ProcessInfo().operatingSystemVersion

        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["X-WT-UA"]?.removingPercentEncoding!).to(equal("Tracking Library \(WebtrekkTracking.version) (\(operatingSystemName) \(version.majorVersion).\(version.minorVersion)\(version.patchVersion == 0 ? "":".\(version.patchVersion)"); \(modelNumber); \(Locale.current.identifier))"))
        }
    }
    
    func testKeyValueOverride(){

        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }

        doURLSendTestAction(){
            let pageTracker = WebtrekkTracking.trackerForAutotrackedViewController(self.mainViewController)
            pageTracker.variables["Key1"]="value1"
            pageTracker.variables["Key2"]="value2"
            pageTracker.variables["KeyOver1"]="overValue1"
            pageTracker.pageProperties.details = [1: "don't Override"]
            self.mainViewController.beginAppearanceTransition(true, animated: false)
            self.mainViewController.endAppearanceTransition()
        }
        
        doURLSendTestCheck(){parametersArr in
            print("key value print for keyValueTestOverride______________")
            for (key, value) in parametersArr{
                print(key+"="+value)
            }
            expect(parametersArr["cp2"]).to(equal("overValue1"))
            expect(parametersArr["cb2"]).to(equal("overValue1"))
            expect(parametersArr["cc2"]).to(equal("overValue1"))
            expect(parametersArr["cs2"]).to(equal("overValue1"))
            //expect(parametersArr["ck2"]).to(equal("overValue1"))
            expect(parametersArr["ca2"]).to(equal("overValue1"))
            expect(parametersArr["cg2"]).to(equal("overValue1"))
            expect(parametersArr["uc2"]).to(equal("overValue1"))
            //expect(parametersArr["mg2"]).to(equal("overValue1"))
            
            expect(parametersArr["cp1"]).to(equal("test_pageparam2Override"))
            expect(parametersArr["cb1"]).to(equal("test_ecomparam1Override"))
            expect(parametersArr["cc1"]).to(equal("test_adparam1Override"))
            expect(parametersArr["cs1"]).to(equal("test_sessionparam1Override"))
            //expect(parametersArr["ck1"]).to(equal("test_actionparam1Override"))
            expect(parametersArr["ca1"]).to(equal("test_productcategory1Override"))
            expect(parametersArr["cg1"]).to(equal("test_pagecategory1Override"))
            expect(parametersArr["uc1"]).to(equal("test_usercategory1Override"))
            //expect(parametersArr["mg1"]).to(equal("test_mediacategory1Override"))
        }
    }
    
    //To be done
    private func oneTest()
    {
        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["one"]).to(equal("1"))
            expect(parametersArr["fns"]).to(equal("1"))
            }
    }
    
    #if !os(tvOS)
    func testOrientation(){
           let parOrientation = "cp783"
        
          if self.mainViewController == nil {
              self.mainViewController = ViewController()
          }

            doURLSendTestAction(){
                self.mainViewController.beginAppearanceTransition(true, animated: false)
                self.mainViewController.endAppearanceTransition()
            }
        
            doURLSendTestCheck(){parametersArr in
                expect(parametersArr[parOrientation]).to(equal("portrait"))
            }
           doURLSendTestAction(){
               self.mainViewController.beginAppearanceTransition(true, animated: false)
               let value = UIInterfaceOrientation.landscapeLeft.rawValue
               UIDevice.current.setValue(value, forKey: "orientation")
               self.mainViewController.endAppearanceTransition()
           }
        
           doURLSendTestCheck(){parametersArr in
               expect(parametersArr[parOrientation]).to(equal("landscape"))
           }
        
            doURLSendTestAction(){
                self.mainViewController.beginAppearanceTransition(true, animated: false)
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.mainViewController.endAppearanceTransition()
            }
            
            doURLSendTestCheck(){parametersArr in
                expect(parametersArr[parOrientation]).to(equal("portrait"))
            }
    }
    #endif
    
    func testOptOut()
    {
        doURLSendTestAction(){
            WebtrekkTracking.isOptedOut = true
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        self.doURLnotSendTestCheck()
        
        doURLSendTestAction(){
            WebtrekkTracking.isOptedOut = false
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
                expect(parametersArr["p"]).notTo(beNil())
            }
    }
    
    // MARK: auto track test
    func testAutoTrack(){
        
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }

        doURLSendTestAction(){
            self.mainViewController.beginAppearanceTransition(true, animated: false)
            self.mainViewController.endAppearanceTransition()
        }
        
        self.timeout = 10
            doURLSendTestCheck(){parametersArr in
                
                
                expect(parametersArr["p"]).to(contain("autoPageName"))
                expect(parametersArr["p"]).to(contain(self.libraryVersion!))
            }

    }
    
    func testPageURLOverrideTest()
    {
        // test incorrect pu parameter is set
        doURLSendTestAction(){
            
            let track = WebtrekkTracking.instance()
            
            track.pageURL = "some incorrect url"
            track.trackPageView(PageProperties(name: "SomePageName", url: "http://www.sample.com"))
        }

        doURLSendTestCheck(){parametersArr in
                expect(parametersArr["pu"]).to(contain("http%3A%2F%2Fwww.sample.com"))
        }
        
        // test correct pu parameter is set
        doURLSendTestAction(){
            
            let track = WebtrekkTracking.instance()
            
            track.pageURL = "https://www.webtrekk.com"
            track.trackPageView(PageProperties(name: "SomePageName", url: "http://www.sample.com"))
        }

        doURLSendTestCheck(){parametersArr in
                expect(parametersArr["pu"]).to(contain("https%3A%2F%2Fwww.webtrekk.com"))
        }
    }
}

