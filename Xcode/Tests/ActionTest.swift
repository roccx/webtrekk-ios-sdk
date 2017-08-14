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
import Nimble
import Webtrekk

class ActionTest: WTBaseTestNew {
    
    func testAction() {
        
        doURLSendTestAction() {
            let track = WebtrekkTracking.instance()
        
            track.trackAction(ActionEvent(actionProperties: ActionProperties(name: "actionName", details: [1: "actionpar1", 2: "actionPar2"]),
                                          pageProperties: PageProperties(name: "someName"),
                                          sessionDetails: [1: "sessionpar1", 2: "sessionpar2"]))
        }
        
        doURLSendTestCheck() { parametersArr in
            expect(parametersArr["ct"]).to(equal("actionName"))
            expect(parametersArr["ck1"]).to(equal("actionpar1"))
            expect(parametersArr["ck2"]).to(equal("actionPar2"))
            expect(parametersArr["cs1"]).to(equal("sessionpar1"))
            expect(parametersArr["cs34"]).to(beNil())
        }

    }
}
