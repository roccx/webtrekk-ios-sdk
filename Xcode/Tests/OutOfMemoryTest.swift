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
//  Created by arsen.vartbaronov on 06.04.17.
//

import XCTest
import Webtrekk

class OutOfMemoryTest: WTBaseTestNew {
    
    override func tearDown() {
        super.tearDown()
        switch self.name {
        case _ where name.range(of: "testOutOfMemory") != nil:
            // at the end unmount should be done
            self.log(text: "testOutOfMemory has been finished")
            
            //wait for unmount
            sleep(2)
        default:
            break
        }
    }

    
    
    override func getConfigName() -> String? {
        return "webtrekk_config_error_log_disabled"
    }
    
    func testGetPath(){
        let finalURL = WTBaseTestNew.getNewQueueBackFolderURL()
        
        guard let url = finalURL else {
            return
        }
        
        WebtrekkTracking.defaultLogger.logDebug("Folder for queue:=\(url.path)")
    }
    
    // this test shouldn't crash that is main idea. Before this test should be descrease memory for storing queue file
    func testOutOfMemory() {
        
        //do test
        self.httpTester.removeStub()
        self.httpTester.addConnectionInterruptionStub()
        
        let tracker = WebtrekkTracking.instance()
        let maxRequestsFirst = 100
        
        for i in 0..<maxRequestsFirst {
            tracker.trackPageView(PageProperties(
                name: "intrupConnection",
                details: [101: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        let lock = NSLock()
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                
                lock.unlock()
            }
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            WebtrekkTracking.defaultLogger.logDebug("message with ID: \(parameters["cp101"].simpleDescription) is received")
        }
        
        doSmartWait(sec: 10)
    }
}
