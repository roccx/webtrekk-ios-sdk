//
//  MigrationTest.swift
//  WebtrekkTest
//
//  Created by arsen.vartbaronov on 15/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Nimble


class AAMigrationTest: HttpBaseTestNew {

    
    override func setUp() {
        super.setUp()
        Webtrekk.startWithServerUrl(NSURL(string: "https://q3.webtrekk.net"), trackId: "542303889946687", samplingRate: 0, sendDelay: 5, appVersionParameter: "100")
    }

    func testMigration(){
        self.doURLSendTestAction(){
            Webtrekk.trackContent("pageNameOld")
        }
        
        self.doURLSendTestCheck(){_ in
            
        }
    }

}
