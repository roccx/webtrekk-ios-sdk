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
import OHHTTPStubs

class HttpBaseTestNew: XCTestCase {
    
    static var request: URLRequest?
    var timeout: TimeInterval = 12
    static var stubDescription: OHHTTPStubsDescriptor?


    override func setUp() {
        super.setUp()
        initHTTPServer()
        print("Test \""+self.name!+"\" is started----------------------------------")
    }
    
    override func tearDown() {
        releaseHTTPServer()
        print("Test \""+self.name!+"\" is finished----------------------------------")
        super.tearDown()
    }

    func initHTTPServer()
    {
        guard HttpBaseTestNew.stubDescription == nil else{
            return
        }
        
        HttpBaseTestNew.stubDescription = stub(condition: isHost("q3.webtrekk.net")){ request in
            
            HttpBaseTestNew.request = request
            
            let stubPath = OHPathForFile("stub.jpg", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject:"image/jpeg" as AnyObject])
        }
        
    }
    
    func releaseHTTPServer()
    {
        if let stubDescr = HttpBaseTestNew.stubDescription {
            OHHTTPStubs.removeStub(stubDescr)
            HttpBaseTestNew.stubDescription = nil
        }
    }
    
    func doURLSendTestAction(_ closure: ()->()){
        HttpBaseTestNew.request = nil
        closure()
    }
    
    private func getReceivedURLParameters(_ query: String) -> [String:String]
    {
        let valueKeys = query.characters.split(separator: "&")
        var keyValueMap = [String: String]()
        
        for valueKey in valueKeys{
            let keyValueArray:[AnySequence<Character>] = valueKey.split(separator: "=")
            if (keyValueArray.count == 2){
                keyValueMap[String(keyValueArray[0])] = String(keyValueArray[1])
            }else
            {
                print("incorrect parameter:"+String(valueKey))
            }
        }
        
        return keyValueMap
    }
    
    func doURLnotSendTestCheck(_ timeout: TimeInterval = 10){
        expect(HttpBaseTestNew.request).toEventually(beNil(), timeout:timeout)
        
    }
    
    func doURLSendTestCheck(_ closure: (_ parameters: [String: String])->())
    {
        expect(HttpBaseTestNew.request).toEventuallyNot(beNil(), timeout:self.timeout)
        
        guard let _ = HttpBaseTestNew.request else{
            return
        }
        NSLog("Send URL is:"+(HttpBaseTestNew.request?.url?.absoluteString)!)
        
        closure(getReceivedURLParameters((HttpBaseTestNew.request?.url?.query)!))
    }
}
