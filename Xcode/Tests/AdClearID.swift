//
//  AdClearID.swift
//  Examples
//
//  Created by Timo Klein on 20/01/17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

import Nimble
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
//  Created by Timo Klein
//

@testable import Webtrekk
import Foundation

class AdClearIDTest: WTBaseTestNew {
    
    override func getConfigName() -> String? {
        switch self.name {
        case let name where name.range(of: "testNoAdClearIdRequiredPageRequest") != nil || name.range(of: "testNoAdClearIdRequiredActionRequest") != nil:
            return "webtrekk_config_no_AdClearId"
        default:
            return "webtrekk_config_auto_parameter_complex"
        }
    }
    
    private func checkIfAdClearIdExists() -> Bool {
        let adClearId = Foundation.UserDefaults.standard.value(forKey: "webtrekk.adClearId")
        
        return adClearId != nil
    }
    
    private func removeAdClearId() {
        Foundation.UserDefaults.standard.removeObject(forKey: "webtrekk.adClearId")
    }
    
    func testAdClearIdGenerationPageRequest() {
        
        if checkIfAdClearIdExists() {
            removeAdClearId()
        }
        
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck() {
            parametersArr in
            let adStr = parametersArr["cs808"]
            expect(adStr).toNot(beNil())
            
            if let _ = adStr {
                expect(UInt64(adStr!)).toNot(beNil())
                if let adNum = UInt64(adStr!) {
                    
                    
                    let maskAppID: UInt64 = ((UInt64(1) << 10) - 1) << 4
                    let maskMilisek: UInt64 = ((UInt64(1) << 39) - 1) << 24
                    
                    expect((adNum & maskAppID) >> 4).to(equal(713))
                    
                    let miliSec = Double((adNum & maskMilisek) >> 24)
                    
                    var dateComponents = DateComponents()
                    dateComponents.year = 2011
                    dateComponents.month = 01
                    dateComponents.day = 01
                    dateComponents.timeZone = TimeZone.current
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    
                    let miliSecNow = Date().timeIntervalSince(Calendar.current.date(from: dateComponents)!) * 1000
                    let miliSec5MinuteAgo = miliSecNow - 5*60*1000
                    expect(miliSec).to(beGreaterThan(miliSec5MinuteAgo))
                    expect(miliSec).to(beLessThan(miliSecNow + 1000))
                }
            }
        
        }
    }
    
    func testNoAdClearIdRequiredPageRequest() {
        if checkIfAdClearIdExists() {
            removeAdClearId()
        }
        
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["cs808"]).to(beNil())
        }
    }
    
    func testAdClearIdGenerationActionRequest() {
        
        if checkIfAdClearIdExists() {
            removeAdClearId()
        }
        
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackAction(ActionEvent(actionProperties: ActionProperties(name: "actionName", details: [:]),
                                                                pageProperties: PageProperties(name: "someName"),
                                                                sessionDetails: [1: "sessionpar1", 2: "sessionpar2"]))
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["cs808"]).toNot(beNil())
        }
    }
    
    func testNoAdClearIdRequiredActionRequest() {
        if checkIfAdClearIdExists() {
            removeAdClearId()
        }
        
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["cs808"]).to(beNil())
        }
    }
}
