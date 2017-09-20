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
//  Created by arsen.vartbaronov on 26/10/16.
//

import Nimble
@testable import Webtrekk

class InitializationTest: WTBaseTestNew {
    
    private var configName: String?
    
    override func getConfigName() -> String? {
        if !self.name.isEmpty {
            if name.range(of: "testIncorrectConfig") != nil {
                return "webtrekk_bad_config"
            } else if (name.range(of: "testTrackIdChange") != nil) {
                return self.configName
            } else {
                return nil
            }
            
        }else {
            WebtrekkTracking.defaultLogger.logError("This test use incorrect configuration")
            return nil
        }
    }
    
    
    //will crash if test not passed.
    func testIncorrectConfig(){
        
        let tracker = WebtrekkTracking.instance()
    
        doURLSendTestAction(){
            tracker.trackPageView("IncorrectConfig")
        }
    }
    
    // test migration configuration from trackID specific to application specific
    func testConfigurationMigration(){
        //make configuration trackID specific.
        let trackId = WebtrekkTracking.instance().trackIds[0]
        migrationTest(trackId)
        migrationTest(trackId + ", " + trackId)
        migrationTest(trackId + "," + trackId)
    }
    
    private func migrationTest(_ baseTrackId: String){
        releaseWebtrekk()
        
        let userDefaults = Foundation.UserDefaults.standard
        
        userDefLoop(source: userDefaults, prefix: "webtrekk."){ (key, value) -> Void in
            //get second part from key
            let keys = key.components(separatedBy: ".")
            
            expect(keys[1].isTrackIdFormat()).to(equal(false))
            
            userDefaults.removeObject(forKey: key)
            
            let altKey = keys[0] + "." + baseTrackId + "." + keys[1]
            
            userDefaults.set(value, forKey: altKey)
        }
        
        initWebtrekk()
        
        //check that there is no item with trackID
        userDefLoop(source: userDefaults, prefix: "webtrekk."){ (key, value) -> Void in
            //get second part from key
            let keys = key.components(separatedBy: ".")
            
            expect(keys[1].isTrackIdFormat()).to(equal(false))
        }
    }
    
    //test that trackId can be changed
    func testTrackIdChange(){
        releaseWebtrekk()
        self.configName = "webtrekk_config_alt_trackid"
        initWebtrekk()
        
        expect(WebtrekkTracking.instance().trackIds[0]).to(equal("123451234512346"))
    }
    
    private func userDefLoop(source: Foundation.UserDefaults, prefix: String, closure: (_ key: String, _ value: Any) -> Void ){
        for (key, value) in source.dictionaryRepresentation() {
            if key.hasPrefix(prefix){
                closure(key, value)
            }
        }
    }
}

