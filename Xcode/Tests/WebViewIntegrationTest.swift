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
//  Created by arsen.vartbaronov on 31/07/17.
//

import XCTest
import Nimble
import WebKit
import Webtrekk

class WebViewIntegrationTest: WTBaseTestNew, WKScriptMessageHandler  {
    
    var mainViewController: ViewController!
    var everId: String?
    
    override func getConfigName() -> String?{
        return String("webtrekk_config_no_completely_autoTrack")
    }
    
    func testIntegration(){
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }
        
        self.everId = nil
        let expectedEverId = WebtrekkTracking.instance().everId
        
        //add listener interface to WKWebView
        let theConfiguration =  WebtrekkTracking.updateWKWebViewConfiguration()
        
        self.mainViewController.configuration = theConfiguration

        theConfiguration?.userContentController.add(self, name: "appCallback")

        doURLSendTestAction(){
           self.mainViewController.beginAppearanceTransition(true, animated: false)
           self.mainViewController.endAppearanceTransition()
        }

        expect(self.everId).toEventuallyNot(beNil(), timeout:3)
        
        expect(self.everId).to(equal(expectedEverId))
    }
    
    // impement WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if message.name == "appCallback" {
            self.everId = message.body as? String
        }
    }
}
