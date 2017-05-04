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
//  Created by arsen.vartbaronov on 30/01/17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

import XCTest
import Nimble
import Webtrekk

/**
 This test is used webtrekk_config.xml with 30 sec delay timeout for new session and test new session determination
 */
class BackToForegroundTest: WTBaseTestNew {
    let maxRequestsFirst = 1000
    
 
    func testPutMesaageToQueue(){
        // put meesage to queue
        self.httpTester.removeStub()
        self.httpTester.addConnectionInterruptionStub()
        
        let tracker = WebtrekkTracking.instance()
        
        for i in 0..<maxRequestsFirst {
            tracker.trackPageView(PageProperties(
                name: "testFromBackground",
                details: [103: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        self.isCheckFinishCondition = false
    }

    func testAllMessageHasBeenReceived(){
        
        var passed = false
        var lastMessageIsReceived = false
        
        let lock = NSLock()
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            WebtrekkTracking.defaultLogger.logDebug("message with ID: \(parameters["cp103"].simpleDescription) is received")
            
            if let mesNum = Int(parameters["cp103"].simpleDescription), mesNum == (self.maxRequestsFirst - 1) {
                lastMessageIsReceived = true
            }
            if let value = parameters["p"]?.contains("testFromBackground"), value, lastMessageIsReceived {
                passed = true
            }
        }
        
        expect(passed).toEventually(equal(true), timeout:20)
        
        WebtrekkTracking.defaultLogger.logDebug("all message are received")
    }
    
    
    func testDummy(){
    }
}
