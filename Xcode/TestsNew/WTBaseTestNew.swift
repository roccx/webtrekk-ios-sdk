//
//  WTBaseTestNew.swift
//  WebtrekkTest
//
//  Created by arsen.vartbaronov on 04/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Webtrekk

class WTBaseTestNew: HttpBaseTestNew {

    override func setUp() {
        super.setUp()
        initWebtrekk()
    }
    
    override func tearDown() {
        releaseWebtrekk()
        super.tearDown()
    }
    
    private func initWebtrekk(){
        
        guard !WebtrekkTracking.isInitialized() else{
            return
        }
        
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        
        try! WebtrekkTracking.initTrack()
    }
    
    private func releaseWebtrekk(){
        //WTBaseTestNew.tracker = nil
    }
}
