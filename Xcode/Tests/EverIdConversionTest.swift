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
//  Created by arsen.vartbaronov on 13/10/17.
//
import XCTest
import Nimble
import Webtrekk

class EverIdConversationTest : WTBaseTestNew {
    
    override func setUp() {
        self.initWebtrekkManualy = true
        super.setUp()
    }
    
    func testEverIdFromV2Conversion() {

        var everId: String = ""
        doURLSendTestAction() {
            //delete current EverId
            self.removeDefSetting(setting: "everId")
            self.removeDefSetting(setting: "migrationCompleted")
            //setup EverId as in V2
            let everIdV2 = SetV2EverID()
            everId = everIdV2.createEverIDLikeV2()
            WebtrekkTracking.defaultLogger.logDebug("everId from V2: \(everId)")
            //do track
            self.initWebtrekk()
            let track = WebtrekkTracking.instance()
            track.trackPageView("someView")
        }
        
        doURLSendTestCheck() { parametersArr in
            expect(parametersArr["eid"]).to(equal(everId))
        }
        
    }
}
