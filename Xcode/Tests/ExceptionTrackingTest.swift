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
//  Created by Arsen Vartbaronov on 09/02/17.
//

import Webtrekk
import Foundation
import Nimble


fileprivate func signalHandler(signalNum: Int32){
    print("old signal handler is called with num: \(signalNum) and default \(String(describing: SIG_DFL))")
}


fileprivate func exceptionHandler(exception: NSException){
    print("old exception handler is called")
}


class ExceptionTrackingTest: WTBaseTestNew {
    
    private var applicationSupportDir: URL? = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    
    override func getConfigName() -> String? {
        switch self.name {
            case let name where name.range(of: "testNoErrorLog") != nil:
            return "webtrekk_config_error_log_no"
            case let name where name.range(of: "testErrorLogDisable") != nil:
            return "webtrekk_config_error_log_disabled"
            case let name where name.range(of: "testCrashException") != nil:
            return "webtrekk_config_error_log_fatal"
            case let name where name.range(of: "testCrashSignal") != nil:
            return "webtrekk_config_error_log_fatal"
            case let name where name.range(of: "testAfterExceptionCrash") != nil:
            return "webtrekk_config_error_log_fatal"
            case let name where name.range(of: "testAfterSignalCrash") != nil:
            return "webtrekk_config_error_log_fatal"
            case let name where name.range(of: "testInfoErrorLog") != nil:
            return "webtrekk_config_error_log_info"
            case let name where name.range(of: "testExceptionTracking") != nil:
            return "webtrekk_config_error_log_exception"
            case let name where name.range(of: "testErrorTracking") != nil:
            return "webtrekk_config_error_log_exception"
            case let name where name.range(of: "testNSErrorTracking") != nil:
            return "webtrekk_config_error_log_exception"
            case let name where name.range(of: "testNoExceptionTracking") != nil:
            return "webtrekk_config_error_log_fatal"
            default:
                WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
            return nil
        }
    }
    
    override func setUp() {
        switch self.name {
        case _ where name.range(of: "testCrashSignal") != nil:
            signal(SIGILL, signalHandler)
            signal(SIGTRAP, signalHandler)
        case _ where name.range(of: "testCrashException") != nil:
            NSSetUncaughtExceptionHandler(exceptionHandler)
            signal(SIGABRT, signalHandler)
        case _ where name.range(of: "testAfterExceptionCrash") != nil:
            self.initWebtrekkManualy = true
        default:
            break
        }
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        switch self.name {
        case _ where name.range(of: "testCrashSignal") != nil:
            signal(SIGILL, SIG_DFL)
            signal(SIGTRAP, SIG_DFL)
        case _ where name.range(of: "testCrashException") != nil:
            NSSetUncaughtExceptionHandler(nil)
            signal(SIGABRT, SIG_DFL)
        default:
            break
        }
    }
    
    func testErrorLogDisable(){
        doURLSendTestAction() {
            WebtrekkTracking.instance().exceptionTracker.trackInfo("ErrorName", message: "ErrorMessage")
        }
        
        doURLnotSendTestCheck()
    }
    
    func testNoErrorLog(){
        doURLSendTestAction() {
            WebtrekkTracking.instance().exceptionTracker.trackInfo("ErrorName", message: "ErrorMessage")
        }
        
        doURLnotSendTestCheck()
    }

    
    // just crash everything with exception
    //name of this test function should be the same as in script on Jenkins server
    func testCrashException() {
        
        clearSavedCrashes()
        DispatchQueue.global(qos: .background).async {
            let exception = ExceptionCreator()
            
            exception.throwCocoaPod()
        }
    }

    
    // just crash everything with signal 4
    //name of this test function should be the same as in script on Jenkins server
    func testCrashSignal() {
        clearSavedCrashes()
        let arr: [Int] = [1, 2, 3]
        
        //generate error
        let _ = arr[3]
    }
    
    func testAfterExceptionCrash(){
        
        self.httpTester.removeStub()
        var requestNum: Int = 0
        var requestsAreDone = false
        
        self.httpTester.addNormalStub(){query in
            let parametersArr = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("1"))
            
            switch requestNum{
            case 0:
                expect(parametersArr["ck911"]).to(equal("Example_of_uncatched_exception"))
                expect(parametersArr["ck912"]).to(equal("Just_for_test"))
                expect(parametersArr["ck913"]).to(contain("ExceptionTrackingTest"))
                expect(parametersArr["ck916"]).to(equal("Key2%3AValue2;Key1%3AValue1;"))// todo
                expect(parametersArr["ck917"]).toNot(beNil())
            case 1:
                expect(parametersArr["ck911"]).to(equal("Signal%3A%20SIGABRT"))
                expect(parametersArr["ck913"]).toNot(beNil())
                requestsAreDone = true
            default:
                expect(true).to(equal(false), description: "To many request after exception")
            }
            requestNum = requestNum + 1
        }
        
        doURLSendTestAction() {
            initWebtrekk()
        }
        
        // wait while all requests are procedded
        doSmartWait(sec: 10)
        
        expect(requestsAreDone).to(equal(true))
    }

    func testAfterSignalCrash(){
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("1"))
            expect(parametersArr["ck911"]).to(equal("Signal%3A%20SIGILL"))
            expect(parametersArr["ck912"]).to(beNil())
            expect(parametersArr["ck913"]).notTo(beNil())
            expect(parametersArr["ck916"]).to(beNil())
            expect(parametersArr["ck917"]).to(beNil())
        }
    }
    
    func testInfoErrorLog(){
        // normal test
        doURLSendTestAction() {
            WebtrekkTracking.instance().exceptionTracker.trackInfo("ErrorName", message: "ErrorMessage")
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("3"))
            expect(parametersArr["ck911"]).to(equal("ErrorName"))
            expect(parametersArr["ck912"]).to(equal("ErrorMessage"))
            expect(parametersArr["ck913"]).to(beNil())
            expect(parametersArr["ck916"]).to(beNil())
            expect(parametersArr["ck917"]).to(beNil())
            let pPar = parametersArr["p"] ?? ""
            let comaChar : [Character] = pPar.filter{ $0 == "," }
            expect(comaChar.count).to(equal(9))
        }
        
        // 255 cut test
        let charName = "n", charMessage = "m"
        doURLSendTestAction() {
            WebtrekkTracking.instance().exceptionTracker.trackInfo(String(repeating: charName, count: 300), message: String(repeating: charMessage, count: 300))
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("3"))
            expect(parametersArr["ck911"]).to(equal(String(repeating: charName, count: 255)))
            expect(parametersArr["ck912"]).to(equal(String(repeating: charMessage, count: 255)))
            expect(parametersArr["ck913"]).to(beNil())
            expect(parametersArr["ck916"]).to(beNil())
            expect(parametersArr["ck917"]).to(beNil())
        }
    }
    
    func testExceptionTracking(){
        
        let char = "2"
        doURLSendTestAction() {
                let exception = NSException(name: NSExceptionName(rawValue: "Swift Exception"), reason: "unit test", userInfo: ["key1":String(repeating: char, count: 300), "key2":"value2"])
                
            WebtrekkTracking.instance().exceptionTracker.trackException(exception)
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("2"))
            expect(parametersArr["ck911"]).to(equal("Swift%20Exception"))
            expect(parametersArr["ck912"]).to(equal("unit%20test"))
            expect(parametersArr["ck916"]).to(equal("key2%3Avalue2;key1%3A"+String(repeating: char, count: 238)))
            expect(parametersArr["ck917"]).to(beNil())
        }
    }
    
    // configuration prohibit tracking
    func testNoExceptionTracking(){
        doURLSendTestAction() {
            let exception = NSException(name: NSExceptionName(rawValue: "Swift Exception"), reason: "unit test", userInfo: ["key1":"value1", "key2":"value2"])
            
            WebtrekkTracking.instance().exceptionTracker.trackException(exception)
        }
        
        doURLnotSendTestCheck()
    }
    
    func testNSErrorTracking(){
        doURLSendTestAction() {
            let error = NSError(domain: "SomeDomain", code: 2, userInfo: ["key1":"NSError", "key2":"value2"] )
            
            WebtrekkTracking.instance().exceptionTracker.trackNSError(error)
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("2"))
            expect(parametersArr["ck911"]).to(equal("NSError"))
            expect(parametersArr["ck912"]).to(equal("code%3A2%2C%20domain%3ASomeDomain"))
            expect(parametersArr["ck916"]).to(equal("key2%3Avalue2;key1%3ANSError;"))
            expect(parametersArr["ck917"]).to(beNil())
        }
    }
    
    class ErrorExample: Error {
        var localizedDescription: String
        
        init() {
            localizedDescription = ""
        }
    }
    
    func testErrorTracking(){
        doURLSendTestAction() {
            do {
                throw ErrorExample()
            }catch let error {
                WebtrekkTracking.instance().exceptionTracker.trackError(error)
            }
        }
        
        doURLSendTestCheck() {
            parametersArr in
            expect(parametersArr["ct"]).to(equal("webtrekk_ignore"))
            expect(parametersArr["ck910"]).to(equal("2"))
            expect(parametersArr["ck911"]).to(equal("Error"))
            expect(parametersArr["ck912"]).to(contain("Tests.ExceptionTrackingTest.ErrorExample"))
            expect(parametersArr["ck916"]).to(beNil())
            expect(parametersArr["ck917"]).to(beNil())
        }
        
    }
    
    //TODO add test for other signals
    private func clearSavedCrashes(){
        let enumerator = FileManager.default.enumerator(atPath: applicationSupportDir!.path)
        
        enumerator?.forEach(){value in
            if let strValue = value as? String, strValue.contains("webtrekk_exception"){
                do {
                    if let removedPath = applicationSupportDir?.appendingPathComponent(strValue).path {
                        WebtrekkTracking.defaultLogger.logDebug("delete file \(removedPath)")
                        try FileManager.default.removeItem(atPath: removedPath)
                    }
                }catch let error{
                    WebtrekkTracking.defaultLogger.logDebug("error deleting file exception is: \(error)")
                }
            }
        }

    }
}
