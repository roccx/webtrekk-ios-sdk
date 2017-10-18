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
    
    override func getConfigName() -> String? {
        
        if !self.name.isEmpty {
            if name.range(of: "testManualSend") != nil {
                return "webtrekk_config_message_send_manual"
            } else if (name.range(of: "testMinimumDelaySend") != nil) {
                return "webtrekk_config_message_send_minimum_delay"
            } else if (name.range(of: "testConnectionInterruption") != nil) {
                return "webtrekk_config_message_send_connection_interruption"
            }else if (name.range(of: "testFileCorruption") != nil) {
                return "webtrekk_config_message_send_manual"
            } else if (name.range(of: "testMigrationFromVersion440") != nil || name.range(of: "testPerformance") != nil || (name.range(of: "testCPULoad") != nil)) {
                return nil
            } else {
                WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
                return nil
            }
            
        }else {
            WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
            return nil
        }
    }
    
    
    override func setUp() {
        switch self.name {
        case _ where name.range(of: "testMigrationFromVersion440") != nil:
            self.initWebtrekkManualy = true
        default:
            break
        }
        super.setUp()
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
        #if os(tvOS)
            let maxRequests = 200
        #else
            let maxRequests = 20000
        #endif

        var currentId = 0
        WebtrekkTracking.defaultLogger.logDebug("Remove interrup connection stub")
        let lock = NSLock()
        
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            expect(parameters["cp100"]).to(equal("\(currentId)"))
            WebtrekkTracking.defaultLogger.logDebug("message with ID: \(parameters["cp100"].simpleDescription) is received")
            currentId += 1
        }
        
        for i in 0..<maxRequests {
            tracker.trackPageView(PageProperties(
                name: "intrupConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        
        expect(currentId).toEventually(equal(maxRequests), timeout:1000, description: "check for max request received")

        // wait for couple seconds so items will be deleted from queue.
        doSmartWait(sec: 2)
    }
    
    func testConnectionInterruptionComplex() {
        self.httpTester.removeStub()
        self.httpTester.addConnectionInterruptionStub()
        
        
        let tracker = WebtrekkTracking.instance()
        #if os(tvOS)
            let maxRequestsFirst = 100
        #else
            let maxRequestsFirst = 10000
        #endif
        let maxRequestSecond = maxRequestsFirst*2
        
        for i in 0..<maxRequestsFirst {
            tracker.trackPageView(PageProperties(
                name: "intrupConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        var currentId = 0
        
        let lock = NSLock()
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            expect(parameters["cp100"]).to(equal("\(currentId)"))
            WebtrekkTracking.defaultLogger.logDebug("message with ID: \(parameters["cp100"].simpleDescription) is received")
            currentId += 1
        }
        
        for i in maxRequestsFirst..<maxRequestSecond {
            tracker.trackPageView(PageProperties(
                name: "interruptConnection",
                details: [100: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        expect(currentId).toEventually(equal(maxRequestSecond), timeout:1000)
        
        // wait for couple seconds so items will be deleted from queue.
        doSmartWait(sec: 2)
    }
    
    func testMigrationFromVersion440(){
        //copy file
        let source = Bundle.main.url(forResource: "requestQueue", withExtension: "archive")
        let destination = WTBaseTestNew.requestOldQueueBackupFileForWebtrekkId(getConfID())
        
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        WebtrekkTracking.defaultLogger.testMode = true
        
        do {
            let destinationToLog = destination?.absoluteString
            let sourceToLog = source?.absoluteString
            WebtrekkTracking.logger.logDebug("source: \(sourceToLog.simpleDescription) destination: \(destinationToLog.simpleDescription)")
            try FileManager.default.copyItem(at: source!, to: destination!)
        } catch let error {
           WebtrekkTracking.logger.logError("can't copy file: \(error)")
        }
        
        //do test
        var currentId = 0
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            currentId += 1
            let parameters = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            expect(parameters["p"]).to(contain("440,"))
        }
        
        try! WebtrekkTracking.initTrack()
    
        //wait for some messages
        expect(currentId).toEventually(equal(9), timeout:5)

        // wait for couple seconds so items will be deleted from queue.
        doSmartWait(sec: 2)
    }
    
    func testPerformance(){
        let tracker = WebtrekkTracking.instance()
        
        var currentId = 0
        let lock = NSLock()
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            lock.lock()
            defer{
                lock.unlock()
            }
            currentId += 1
        }
        
        self.measure {
            tracker.trackPageView("performanceTest")
        
        }

        expect(currentId).toEventually(equal(10), timeout:20)
        
        doSmartWait(sec: 2)
    }
    
    func testCPULoad(){
        httpTester.removeStub()
        
        var runThread: Bool = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            while runThread{
                let n: Double = 45.0
                let _ = sqrt(n)
            }
        }
        
        let tracker = WebtrekkTracking.instance()
        let maxRequests = 1000
        var currentId = 0
        
        self.httpTester.addNormalStub(){query in
            currentId += 1
            WebtrekkTracking.logger.logDebug("currentId increased: \(currentId)")
        }
        
        for _ in 0..<maxRequests {
            tracker.trackPageView("CPULoadTest")
            doSmartWait(sec: 0.0001)
        }
        
        expect(currentId).toEventually(equal(maxRequests), timeout:100, description: "check for max request received CPU Load")
        
        DispatchQueue.global(qos: .userInteractive).sync {
            runThread = false
        }

        // wait for couple seconds so items will be deleted from queue.
        doSmartWait(sec: 2)
    }
    
    
    func testFileCorruption(){
        //do test
        
        // put meesage to file

        let tracker = WebtrekkTracking.instance()
        let maxRequestsFirst = 200
        
        for i in 0..<maxRequestsFirst {
            tracker.trackPageView(PageProperties(
                name: "testFileCorruption",
                details: [101: .constant("\(i)")],
                groups: nil,
                internalSearch: nil,
                url: nil))
            doSmartWait(sec: 0.0001)
        }
        
        doSmartWait(sec: 5)
        
        //put garbage to file
        let finalURL = WTBaseTestNew.getNewQueueBackFileURL()
        
        guard let url = finalURL, let fileHandler = try? FileHandle(forUpdating: url) else {
            expect(true).to(equal(false), description: "Can't get saved path for file or create handler")
            return
        }
        
        // setup file handler
        
        let rand = arc4random_uniform(2048)
        let preservePosition = fileHandler.offsetInFile
        let endOfFilePosition = fileHandler.seekToEndOfFile()
        let randomPosition = endOfFilePosition - UInt64(8096) + UInt64(rand)
        
        WebtrekkTracking.defaultLogger.logDebug("preservePosition: \(preservePosition), endofFile: \(endOfFilePosition), random: \(randomPosition)")
        
        
        fileHandler.seek(toFileOffset: UInt64(integerLiteral: randomPosition))
        
        //generate garbage
        var randArray = [UInt8]()
        
        for i in 0..<2024 {
            randArray.append(UInt8(arc4random_uniform(255)))
        }
        
        fileHandler.write(Data(randArray))
        
        //restore position
        fileHandler.seek(toFileOffset: preservePosition)
        
        //try to send
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
        
        tracker.sendPendingEvents()
        
        //test shouldn't crash
        
        doSmartWait(sec: 20)
        
        WebtrekkTracking.defaultLogger.logDebug("finishWait")

    }
    
}
