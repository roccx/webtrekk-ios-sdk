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
import Foundation
import AdSupport
import Nimble
import UIKit
import Webtrekk

class AttributionTest: WTBaseTestNew {
    
    private let mediaCode = "media_code"
    private let mediaCodePostBack = "media_code_postback"
    

    override func getConfigName() -> String?{
        return "webtrekk_config_no_completely_autoTrack"
    }
    
    //do just global parameter test
    func testStartAttributionWithIDFA(){
        startAttributionTest(useIDFA: true)
    }
    
    //do just global parameter test
    func testStartAttributionWithoutIDFA(){
        startAttributionTest(useIDFA: false)
    }
    
    override func setUp() {
        if self.name.range(of: "testAppInstallFirstInstallation") != nil || self.name.range(of: "testAppInstallWithPostCallback") != nil {
            self.removeDefSetting(setting: "appinstallGoalProcessed")
        }
        
        if self.name.range(of: "testStartAttributionWithIDFA") != nil || self.name.range(of: "testStartAttributionWithoutIDFA") != nil {
            self.isWaitForCampaignFinished = false
        }
        
        if self.name.range(of: "testAppInstallWithPostCallback") != nil {
            self.removeDefSetting(setting: "campaignHasProcessed")
            self.removeDefSetting(setting: "mediaCode")
            
            self.doPostCall()
            
        }

        super.setUp()
    }
    
    private func startAttributionTest(useIDFA: Bool){
        
        // get track id
        let trackerID = "123451234512345"
        
        // get adv
        let advID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        
        var url = "https://appinstall.webtrekk.net/appinstall/v1/redirect?mc="+mediaCode+"&trackid="+trackerID+"&as2=https%3A//itunes.apple.com/de/app/apple-store/id375380948%3Fmt%3D8"
        
        if useIDFA && advID != "00000000-0000-0000-0000-000000000000" {
            url = url + "&aid=" + advID
        }
        
        WebtrekkTracking.defaultLogger.logDebug("open url for installation test:"+url)
        
        UIApplication.shared.openURL(URL(string:url)!)
    }
    

    func testInstallation() {
        
        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["mc"]).to(equal(mediaCode))
            expect(parametersArr["mca"]).to(equal("c"))
            expect(parametersArr["cb900"]).to(equal("1"))
        }
        
        //wait till message is processed and deleted from queue
        doSmartWait(sec: 2)
    }
    
    //test should be done with already installes and started application
    func testAppInstallNoFirstInstallation(){

        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["cb900"]).to(beNil())
        }
    }

    func testAppInstallFirstInstallation(){
        
        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["cb900"]).to(equal("1"))
        }
    }
    
    func testAppInstallWithPostCallback(){
        
        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["mc"]).to(equal(mediaCodePostBack))
            expect(parametersArr["mca"]).to(equal("c"))
            expect(parametersArr["cb900"]).to(equal("1"))
        }
    }
    
    private func doPostCall(){
        let session = URLSession.shared
        
        let trackerId = "123451234512345"
        
        // get adv
        let advID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        let url = "https://appinstall.webtrekk.net/appinstall/v1/postback?mc=\(mediaCodePostBack)&trackid=\(trackerId)&app_name=null&aid=\(advID)"
        
        NSLog("call postback url: \(url)")
        
        let task = session.dataTask(with: URLRequest(url: URL(string: url)!)) { data, response, error in
            if let error = error {
                NSLog("incorrect post request \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
}
