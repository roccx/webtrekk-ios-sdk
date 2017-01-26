//
//  AdClearID.swift
//  Examples
//
//  Created by Timo Klein on 20/01/17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

import Nimble
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
                                                                sessionDetails: [:]))
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
