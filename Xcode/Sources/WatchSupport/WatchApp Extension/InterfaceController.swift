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
//  Created by arsen.vartbaronov on 04/11/16.
//

import WatchKit
import Foundation
@testable import Webtrekk


class InterfaceController: WKInterfaceController, RequestManager.Delegate {
    
    let httpTester = HTTPTester()
    var currentTestNumber = 0
    weak var originDelegate: RequestManager.Delegate?
    var userAgent: String!
    
    private typealias Parameters = [String: String]
    private typealias TestData = [(parName: String, expected: String)]

    @IBOutlet var test1Label: WKInterfaceLabel!
    @IBOutlet var test2Label: WKInterfaceLabel!
    
    @IBAction func NextPage() {
        pushController(withName: "Page2", context: 1)
    }
    
    override init(){
        super.init()
        
        let version = ProcessInfo().operatingSystemVersion
        self.userAgent = "Tracking Library \(WebtrekkTracking.version) (watchOS \(version.majorVersion).\(version.minorVersion)\(version.patchVersion == 0 ? "":".\(version.patchVersion)"); \(Environment.deviceModelString); \(Locale.current.identifier))"
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //passed all tests
        guard self.currentTestNumber != 3 else {
            return
        }
        
        if self.currentTestNumber != 2 {
            // start first test. Init stub
            self.initSpecficStub()

            startTest() {
                self.currentTestNumber = 1
                WebtrekkTracking.instance().trackPageView("SimpleWatchPage")
            }
        } else {
            
            finishTest(){parameters in
                guard let parameters = parameters else{
                    self.logTestResult(isPassed: false, testNum: 2)
                    return
                }

                let testData: TestData = [("fns", "0"),("X-WT-UA", self.userAgent),
                                          ("cg1", "test_pagecategory1Override"), ("uc1", "test_usercategory1Override")]
                
                if self.parameterTests(values: testData, parameters: parameters) && parameters["p"]?.contains("autoWatchPageName") ?? false {
                    self.test2Label.setText("Test 2 Passed")
                    self.logTestResult(isPassed: true, testNum: 2)
                } else {
                    self.test2Label.setText("Test 2 Failed")
                    self.logTestResult(isPassed: false, testNum: 2)
                }
                
                self.currentTestNumber = 3
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didAppear() {
        guard self.currentTestNumber != 2 && self.currentTestNumber != 3 else {
            return
        }
        finishTest(){parameters in
            // add checking parameters

            guard let parameters = parameters else{
                self.logTestResult(isPassed: false, testNum: 1)
                return
            }
            
            let testData: TestData = [("fns", "1"),("X-WT-UA", self.userAgent),
                                      ("ca1", "test_productcategory1"), ("uc1", "test_usercategory1")]
            
            if self.parameterTests(values: testData, parameters: parameters) && parameters["p"]?.contains("SimpleWatchPage") ?? false {
                self.test1Label.setText("Test 1 Passed")
            } else {
                self.test1Label.setText("Test 1 Failed")
                self.logTestResult(isPassed: false, testNum: 1)
            }
            self.startTest(){
                self.currentTestNumber = 2
                self.pushController(withName: "Page2", context: nil)
            }
        }
    }
    
    private func startTest(action: ()->()){
        HTTPTester.request = nil
        action()
    }
    
    private func parameterTests(values: TestData, parameters: Parameters) -> Bool{
        
        var returnValue = true
        
        for value in values {
            let actual = parameters[value.parName]?.removingPercentEncoding
            if actual == nil || actual != value.expected {
               self.log("Test Error: expected parameter \(value.parName)=\(value.expected), but actual value:\(actual ?? "nil")")
                returnValue = false
            }
        }
        
        return returnValue
    }
    
    
    private func finishTest(action: @escaping (_ parameters: Parameters?)->()){
        
        DispatchQueue.global().async() {
            let date = Date(timeIntervalSinceNow: 600)
            
            while HTTPTester.request == nil && date.compare(Date()) == .orderedDescending {
                sleep(1)
            }
            
            guard let _ = HTTPTester.request else{
                self.log("Test execution error")
                action(nil)
                return
            }
            
            self.log("WatchOS. Send URL has been received")
            
            DispatchQueue.main.async(){
                action(self.httpTester.getReceivedURLParameters((HTTPTester.request?.url?.query)!))}
        }
    }
    
    private func initSpecficStub(){
        self.log("Init specificStup")

        let defaultTracker = WebtrekkTracking.instance() as! DefaultTracker
        
        
        guard let requestManager = defaultTracker.requestManager else {
            self.log("Error: request manager is null. Can't establish delegate")
            return
        }
        
        self.originDelegate = requestManager.delegate
        
        requestManager.delegate = self
    }
    
    func requestManager (_ requestManager: RequestManager, didSendRequest request: URL){
        HTTPTester.request = URLRequest(url: request)
        self.log("Request catched by delegate.")
        self.originDelegate?.requestManager(requestManager, didSendRequest: request)
    }
    
    func requestManager (_ requestManager: RequestManager, didFailToSendRequest request: URL, error: RequestManager.ConnectionError){
        self.log ("failed request with error \(error).")
        self.originDelegate?.requestManager(requestManager, didFailToSendRequest: request, error: error)
    }
    
    private func logTestResult(isPassed: Bool, testNum: Int = 0){
        self.log("Test \(testNum) result.")
        self.log("Webtrekk WatchApp Test \(isPassed ? "passed":"failed")")
    }
    
    private func log(_ text: String){
        WebtrekkTracking.defaultLogger.logDebug(text)
    }
}
