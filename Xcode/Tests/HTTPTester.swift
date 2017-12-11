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
//  Created by arsen.vartbaronov on 10/11/16.
//
import OHHTTPStubs
import Webtrekk

class HTTPTester {
    static var request: URLRequest?
    static var stubDescription: OHHTTPStubsDescriptor?
    
    func initHTTPServer()
    {
        guard HTTPTester.stubDescription == nil else{
            return
        }
        
        addStandardStub()
    }
    
    func addStandardStub(){
        addNormalStub(process: {HTTPTester.request = $0})
    }
    
    
    func addNormalStub(process closure: @escaping (_ query: URLRequest)->())
    {
        HTTPTester.stubDescription = stub(condition: filterConditions()){ request in
            
            closure(request)
            
            let stubPath = OHPathForFile("stub.jpg", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type" as NSObject:"image/jpeg" as AnyObject])
        }
    }
    
    func removeStub(){
        if let stubDescr = HTTPTester.stubDescription {
            OHHTTPStubs.removeStub(stubDescr)
            HTTPTester.stubDescription = nil
        }
    }
    
    func filterConditions()->OHHTTPStubsTestBlock{
        return {req in req.url?.host == "q3.webtrekk.net" || (req.url?.host == "localhost" && req.url?.port == 8080)}
    }
    
    
    
    func addConnectionInterruptionStub(){
        HTTPTester.stubDescription = stub(condition: filterConditions()){ request in
            
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:NSURLErrorNotConnectedToInternet, userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
        }
    }
    
    func releaseHTTPServer()
    {
        removeStub()
    }

    func getReceivedURLParameters(_ query: String) -> [String:String]
    {
        guard !query.isEmpty else {
            WebtrekkTracking.defaultLogger.logDebug("empty query")
            return [:]
        }
        let valueKeys = query.split(separator: "&")
        var keyValueMap = [String: String]()
        
        for valueKey in valueKeys{
            let keyValueArray:[AnySequence<Character>] = valueKey.split(separator: "=")
            if (keyValueArray.count == 2){
                keyValueMap[String(keyValueArray[0])] = String(keyValueArray[1])
            }else
            {
                WebtrekkTracking.defaultLogger.logDebug("incorrect parameter:"+String(valueKey))
            }
        }
        
        return keyValueMap
    }
}
