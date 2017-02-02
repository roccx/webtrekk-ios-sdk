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
//  Created by arsen.vartbaronov on 30/01/17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

import XCTest
import Nimble
import Webtrekk

/**
 This test is used webtrekk_config.xml with 30 sec delay timeout for new session and test new session determination
 */
class BackToForegroundTest: WTBaseTestNew {
    
 
    func testDummy(){
    }

    func testCheckBackToForegroundNoNewSession(){
        checkForNewSession(false)
    }
    
    func testCheckBackToForegroundWithNewSession(){
        checkForNewSession(true)
    }
    
    private func checkForNewSession(_ isNewSession: Bool){
        
        doURLSendTestAction(){
            let mainViewController = ViewController()
            
            mainViewController.beginAppearanceTransition(true, animated: false)
            mainViewController.endAppearanceTransition()
        }

        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["fns"]).to(equal(isNewSession ? "1" : "0"))
        }
    }
}
