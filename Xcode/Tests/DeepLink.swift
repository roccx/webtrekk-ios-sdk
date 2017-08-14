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
//  Created by arsen.vartbaronov on 11/09/16.
//

import XCTest
import Nimble
import Webtrekk
import WebKit


class DeepLink: WTBaseTestNew {

    func testSetEverIDAndMediaCode() {
        
        let everId = "1234567890123456789"
        let incorrectEverID = "12345653434"
        let mediaCode = "SomeCode"
        
        // test correct EverID
        doURLSendTestAction(){
            let track = WebtrekkTracking.instance()
            
            track.everId = everId
            track.mediaCode = mediaCode
            
            track.trackPageView("SomePage")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["mc"]).to(contain(mediaCode))
            expect(parametersArr["eid"]).to(equal(everId))
        }
        
        //test incorrect EverID
        doURLSendTestAction(){
            let track = WebtrekkTracking.instance()
            
            track.everId = incorrectEverID
            
            track.trackPageView("SomePage")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["mc"]).to(beNil())
            expect(parametersArr["eid"]).to(equal(everId))
        }
        
    }
    
    func testDeepLink(){
        
        // test With emulation of opening
        let everId = "1234567890123456700"
        let mediaCode = "mediaCodeURL"

        doURLSendTestAction(){
            let url = URL(string: "https://www.webtrekk.com?wt_everID=\(everId)&wt_mediaCode=\(mediaCode)")
            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            userActivity.webpageURL = url
            
            let _ = UIApplication.shared.delegate?.application!(UIApplication.shared,
            continue: userActivity){
                (_: [Any]?) -> Void in
            }
            
            WebtrekkTracking.instance().trackPageView("SomePage")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["mc"]).to(contain(mediaCode))
            expect(parametersArr["eid"]).to(equal(everId))
        }

    }
}
