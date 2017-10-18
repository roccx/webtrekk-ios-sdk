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
import Webtrekk

class HttpBaseTestNew: XCTestCase {
    
    var timeout: TimeInterval = 12
    let httpTester = HTTPTester()

    override func setUp() {
        super.setUp()
        httpTester.initHTTPServer()
        print("Test \""+self.name+"\" is started----------------------------------")
    }
    
    override func tearDown() {
        httpTester.releaseHTTPServer()
        print("Test \""+self.name+"\" is finished----------------------------------")
        super.tearDown()
    }
    
    func doURLSendTestAction(_ closure: ()->()){
        HTTPTester.request = nil
        closure()
    }
    
    func doURLnotSendTestCheck(_ timeout: TimeInterval = 10){
        expect(HTTPTester.request).toEventually(beNil(), timeout:timeout)
        
    }
    
    func doURLSendTestCheck(_ closure: (_ parameters: [String: String])->())
    {
        expect(HTTPTester.request).toEventuallyNot(beNil(), timeout:self.timeout, pollInterval: 0.1)
        
        guard let _ = HTTPTester.request else{
            return
        }
        WebtrekkTracking.defaultLogger.logDebug("Send URL is:" + (HTTPTester.request?.url?.absoluteString ?? "null"))
        
        closure(httpTester.getReceivedURLParameters((HTTPTester.request?.url?.query ?? "")))
    }
}

internal extension Optional where Wrapped == String{
    internal var simpleDescription: String {
        return map { String(describing: $0) } ?? "<nil>"
    }
}
