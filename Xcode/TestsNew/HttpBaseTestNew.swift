//
//  HttpBaseTestNew.swift
//  WebtrekkTest
//
//  Created by arsen.vartbaronov on 04/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs

class HttpBaseTestNew: XCTestCase {
    
    static var request: NSURLRequest?
    var timeout: NSTimeInterval = 12
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
        
        HttpBaseTestNew.stubDescription = stub(isHost("q3.webtrekk.net")){ request in
            
            HttpBaseTestNew.request = request
            
            let stubPath = OHPathForFile("stub.jpg", self.dynamicType)
            return fixture(stubPath!, headers: ["Content-Type":"image/jpeg"])
        }
        
    }
    
    func releaseHTTPServer()
    {
        if let stubDescr = HttpBaseTestNew.stubDescription {
            OHHTTPStubs.removeStub(stubDescr)
            HttpBaseTestNew.stubDescription = nil
        }
    }
    
    func doURLSendTestAction(closure: ()->()){
        HttpBaseTestNew.request = nil
        closure()
    }
    
    private func getReceivedURLParameters(query: String) -> [String:String]
    {
        let valueKeys = query.characters.split("&")
        var keyValueMap = [String: String]()
        
        for valueKey in valueKeys{
            let keyValueArray:[AnySequence<Character>] = valueKey.split("=")
            if (keyValueArray.count == 2){
                keyValueMap[String(keyValueArray[0])] = String(keyValueArray[1])
            }else
            {
                print("incorrect parameter:"+String(valueKey))
            }
        }
        
        return keyValueMap
    }
    
    func doURLnotSendTestCheck(timeout: NSTimeInterval = 10){
        expect(HttpBaseTestNew.request).toEventually(beNil(), timeout:timeout)
        
    }
    
    func doURLSendTestCheck(closure: (parameters: [String: String])->())
    {
        expect(HttpBaseTestNew.request).toEventuallyNot(beNil(), timeout:self.timeout)
        
        guard let _ = HttpBaseTestNew.request else{
            return
        }
        NSLog("Send URL is:"+(HttpBaseTestNew.request?.URL?.absoluteString)!)
        
        closure(parameters: getReceivedURLParameters((HttpBaseTestNew.request?.URL?.query)!))
    }
}
