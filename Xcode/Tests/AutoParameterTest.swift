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
//  Created by arsen.vartbaronov on 21/11/16.
//

import Nimble
@testable import Webtrekk
import Foundation

class AutoParameterTest: WTBaseTestNew {
    
    override func getConfigName() -> String?{
        if name.range(of: "testAutoParameterComplex") != nil {
            return "webtrekk_config_auto_parameter_complex"
        } else {
            return nil
        }
    }
    
    //
    func testAutoParameterSimple()
    {
        doURLSendTestAction(){
            WebtrekkTracking.instance().trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["cs804"]).to(equal("1.0"))
            #if !os(tvOS)
                expect(parametersArr["cs807"]).to(equal("WIFI"))
                expect(parametersArr["cp783"]).toNot(beNil())
            #endif
            expect(parametersArr["cp784"]).toNot(beNil())
            expect(parametersArr["cs809"]).toNot(beNil())
            expect(parametersArr["cs813"]).toNot(beNil())
        }
    }

    func testAutoParameterComplex()
    {
        let over804 = "versionOver"
        let over804Key = "versionOverKey"
        let over784 = "requestSizeOver"
        let over809 = "over809"
        
        doURLSendTestAction(){
            WebtrekkTracking.instance()[over804Key] = over804
            WebtrekkTracking.instance().trackPageView("pageName", sessionDetails:[809: .constant(over809)])
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["cs804"]).to(equal(over804))
            #if !os(tvOS)
                expect(parametersArr["cs807"]).to(equal("WIFI"))
                expect(parametersArr["cp783"]).toNot(beNil())
            #endif
            expect(parametersArr["cp784"]).toNot(equal(over784))
            expect(parametersArr["cs809"]).to(equal(over809))
            expect(parametersArr["cs813"]).toNot(beNil())
        }
    }


}
