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
//  Created by arsen.vartbaronov on 13/01/17.
//

import XCTest
import Nimble
@testable import Webtrekk

import Foundation
import AdSupport

class AttributionTest: WTBaseTestNew {
    
    let mediaCode = "media_code"
    
    //do just global parameter test
    func testStartAttibutionTest(){
       // get track id
       let trackerID = "123451234512345"
        
       // get adv
       let advID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        
       var url = "http://appinstall.webtrekk.net/appinstall/v1/redirect?mc="+mediaCode+"&trackid="+trackerID+"&as1=https%3A//itunes.apple.com/de/app/apple-store/id375380948%3Fmt%3D8"
        
        if advID != "00000000-0000-0000-0000-000000000000" {
            url = url + "&aid=" + advID
        }
        WebtrekkTracking.defaultLogger.logDebug("open url:"+url)
        UIApplication.shared.openURL(URL(string:url)!)
        
        let argument = UserDefaults.standard.value(forKey: "startAttributionTest")
        let argument2 = UserDefaults.standard.value(forKey: "startAttributionTest")
        WebtrekkTracking.defaultLogger.logDebug("startAttributionTest= \(argument)")
        WebtrekkTracking.defaultLogger.logDebug("-startAttributionTest= \(argument2)")
        
    }
}
