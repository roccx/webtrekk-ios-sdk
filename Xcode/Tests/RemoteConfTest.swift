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
//  Created by arsen.vartbaronov on 14/12/16.
//

import XCTest
import Nimble
@testable import Webtrekk

class RemoteConfTest: WTBaseTestNew {
    
    override func getConfigName() -> String?{
        
        switch self.name {
        case let name where name.range(of: "testConfigOK") != nil:
            return "webtrekk_config_remote_test_exists"
        case let name where name.range(of: "testLoadDefaultOK") != nil:
            return "webtrekk_config_remote_test_not_exists"
        case let name where name.range(of: "testBrokenConfigLoad") != nil:
            return "webtrekk_config_remote_test_broken_scheme"
        case let name where name.range(of: "testEmptyConfigLoad") != nil:
            return "webtrekk_config_remote_test_empty_file"
        case let name where name.range(of: "testLocked") != nil:
            return "webtrekk_config_remote_test_locked"
        case let name where name.range(of: "testLargeSize") != nil:
            return "webtrekk_config_remote_test_large_size"
        case let name where name.range(of: "testTagIntegration") != nil:
            return "webtrekk_config_remote_test_tag_integration"
        default:
            WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
            return nil
        }
    }
    
    
    override func tearDown() {
        self.removeDefSetting(setting: "configuration")
        super.tearDown()
    }

    
    
    func testConfigOK()
    {
        commonTest(isLocalShouldUse: false);
    }
    
    func testLoadDefaultOK()
    {
        commonTest(isLocalShouldUse: true);
    }
    
    func testBrokenConfigLoad()
    {
        commonTest(isLocalShouldUse: true);
    }
    
    func testEmptyConfigLoad()
    {
        commonTest(isLocalShouldUse: true);
    }
    
    func testLocked()
    {
        commonTest(isLocalShouldUse: true);
    }
    
    func testLargeSize()
    {
        commonTest(isLocalShouldUse: true);
    }
    
    func testTagIntegration()
    {
        commonTest(isLocalShouldUse: false);
    }
    
    func commonTest(isLocalShouldUse: Bool){
        
        // wait for update configuration
        var attempt: Int = 0
        WebtrekkTracking.defaultLogger.logDebug("start wait for configuration update")
        while (!checkDefSetting(setting: "configuration") && attempt < 16){
            doSmartWait(sec: 2)
            attempt += 1
        }
        WebtrekkTracking.defaultLogger.logDebug("end wait for configuration update")
        
        doURLSendTestAction(){
            let defTracker = WebtrekkTracking.instance()
            defTracker["localUsed"] = "localConfUsed"
            defTracker.trackPageView("pageName")
        }
        
        doURLSendTestCheck(){parametersArr in
            if isLocalShouldUse {
                expect(parametersArr["cs3"]).to(equal("localConfUsed"))
            }else {
                expect(parametersArr["cs3"]).to(beNil())
            }
        }
    }
    
}
