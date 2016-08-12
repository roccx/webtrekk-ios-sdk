//
//  ActionTest.swift
//  WebtrekkTest
//
//  Created by arsen.vartbaronov on 01/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Webtrekk

class ActionTest: WTBaseTestNew {
    
    func testAction(){
        
        doURLSendTestAction(){
        let track = WebtrekkTracking.instance()
        
        track.trackAction(ActionEvent(actionProperties: ActionProperties(name: "actionName", details: [1: "actionpar1", 2: "actionPar2"]), pageProperties: PageProperties(name: "someName"),
            sessionDetails: [1: "sessionpar1", 2: "sessionpar2"]))
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["ct"]).to(equal("actionName"))
            expect(parametersArr["ck1"]).to(equal("actionpar1"))
            expect(parametersArr["ck2"]).to(equal("actionPar2"))
            expect(parametersArr["cs1"]).to(equal("sessionpar1"))
        }

    }
}
