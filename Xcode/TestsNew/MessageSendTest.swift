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
//  Created by arsen.vartbaronov on 20/10/16.
//
import XCTest
import Nimble
import Webtrekk

class MessageSendTest: WTBaseTestNew {
    
    override func getCongigName() -> String? {
        
        if let name = self.name {
            if name.range(of: "testManualSend") != nil {
                return "webtrekk_config_message_send_manual"
            } else if (name.range(of: "testMinimumDelaySend") != nil) {
                return "webtrekk_config_message_send_minimum_delay"
            } else if (name.range(of: "testConnectionInterruption") != nil) {
                return "webtrekk_config_message_send_connection_interruption"
            } else {
                WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
                return nil
            }
            
        }else {
            WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
            return nil
        }
    }
    
    func testManualSend(){
        let tracker = WebtrekkTracking.instance()
        
        doURLSendTestAction(){
            tracker.trackPageView("ManualSendPageName")
        }
        
        doURLnotSendTestCheck(15)

        doURLSendTestAction(){
            tracker.sendPendingEvents()
        }
        
        doURLSendTestCheck(){parametersArr in
        expect(parametersArr["p"]).to(contain("ManualSendPageName"))
        }
    }
 
    func testMinimumDelaySend(){
        
        let tracker = WebtrekkTracking.instance()
        
        doURLSendTestAction(){
            tracker.trackPageView("minimumDelayPageName")
        }
       
        timeout = 2
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("minimumDelayPageName"))
        }
    }
    
    func testConnectionInterruption() {
        httpTester.removeStub()
        httpTester.addConnectionInterruptionStub()
        
        
        let tracker = WebtrekkTracking.instance()
        let maxRequests = 20000

        for i in 0..<maxRequests {
            tracker.trackPageView(PageProperties(
                name: "intrupConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
        }
        
        var currentId = 0
        
        self.doURLSendTestAction(){
            self.httpTester.removeStub()
            self.httpTester.addNormalStub(){query in
                let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
                
                expect(parameters["cp100"]).to(equal("\(currentId)"))
                currentId += 1
            }
        }
        
        expect(currentId).toEventually(equal(maxRequests), timeout:200)
    }
    
    func testConnectionInterruptionComplex() {
        self.httpTester.removeStub()
        self.httpTester.addConnectionInterruptionStub()
        
        
        let tracker = WebtrekkTracking.instance()
        let maxRequestsFirst = 10000, maxRequestSecond = maxRequestsFirst*2
        
        for i in 0..<maxRequestsFirst {
            tracker.trackPageView(PageProperties(
                name: "intrupConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
        }
        
        var currentId = 0
        
        self.doURLSendTestAction(){
            self.httpTester.removeStub()
            self.httpTester.addNormalStub(){query in
                let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
                
                expect(parameters["cp100"]).to(equal("\(currentId)"))
                currentId += 1
            }
        }
        
        expect(currentId).toEventually(beGreaterThan(1), timeout:1)
        
        for i in maxRequestsFirst..<maxRequestSecond {
            tracker.trackPageView(PageProperties(
                name: "interruptConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
        }
        
        expect(currentId).toEventually(equal(maxRequestSecond), timeout:200)
    }
    
}
