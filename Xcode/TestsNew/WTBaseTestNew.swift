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
@testable import Webtrekk
import Foundation

class WTBaseTestNew: HttpBaseTestNew {

    override func setUp() {
        super.setUp()
        initWebtrekk()
    }
    
    override func tearDown() {
        releaseWebtrekk()
        super.tearDown()
    }
    
    func getCongigName() -> String?{
        return nil
    }
    
    private func initWebtrekk(){
        
        guard !WebtrekkTracking.isInitialized() else{
            return
        }
        
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        
        if let configName = getCongigName(){
            let configFileURL = Bundle.main.url(forResource: configName, withExtension: "xml")
            try! WebtrekkTracking.initTrack(configFileURL)
        }else {
            try! WebtrekkTracking.initTrack()
        }
    }
    
    private func releaseWebtrekk(){
        rollBackAutoTrackingMethodsSwizz()
        resetWebtrackInstance()
    }
    
    private func resetWebtrackInstance()
    {
        weak var weakTracker = WebtrekkTracking.tracker
        WebtrekkTracking.tracker = nil
        
        while weakTracker != nil {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow:2))
        }
    }
        
    private func rollBackAutoTrackingMethodsSwizz(){
        UIViewController.setUpAutomaticTracking()
    }
}
