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
    
    override func getCongigName() -> String? {
        switch self.name {
        case let name where name?.range(of: "testNoAdClearIdRequiredPageRequest") != nil || name?.range(of: "testNoAdClearIdRequiredActionRequest") != nil:
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
            expect(parametersArr["cs808"]).toNot(beNil())
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
