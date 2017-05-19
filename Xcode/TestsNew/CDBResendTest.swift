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
//  Created by Webtrekk on 19/05/17.
//

import XCTest
import Nimble
import Webtrekk

class CDBResendTest: WTBaseTestNew {
    
    override func getConfigName() -> String? {
        switch self.name {
        case let name where name?.range(of: "testCDB1") != nil:
            return "webtrekk_config_CDB_cdbUpdateInterval_1day"
        default:
            return "webtrekk_config_CDB_cdbUpdateInterval_1sec"
        }
    }
  
    override func setUp() {
        super.setUp()
        clearLocalSettings()
    }
    
    
    override func tearDown() {
        super.tearDown()
        clearLocalSettings()
    }

    
    /// reset relevant local settings on the device:
    private func clearLocalSettings() {
        Foundation.UserDefaults.standard.removeObject(forKey: "webtrekk.CrossDeviceProperties")
        Foundation.UserDefaults.standard.removeObject(forKey: "webtrekk.lastCdbPropertiesSentTime")
    }
    
    // define crossDeviceProperties used by these tests:
    var crossDeviceProperties = CrossDeviceProperties(
        address: .plain(CrossDeviceProperties.Address(
            firstName: "Elmo",
            lastName: "Monster",
            street: "Sesame Street",
            streetNumber: "5",
            zipCode: "90210"
        )),
        androidId: "12345",
        emailAddress: .plain("mail@test.de"),
        facebookId: "facebookId123",
        googlePlusId: "googlePlusId123",
        iosId: "iOSId123",
        linkedInId: "linkedInId123",
        phoneNumber: .hashed(md5: "55512345".md5(), sha256: nil),
        twitterId: "twitterId123",
        windowsId: "windowsId123",
        custom: [3:"three333",8:"eight888"]
    )
    
    
    /// Test to make sure that the CDB properties are not resent before the cdbUpdateInterval has passed
    func testCDB1(){
        
        // do a CDB tracking request:
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackCDB(crossDeviceProperties)
        }
        
        // validate that all CDB properties were sent:
        doURLSendTestCheck() {parametersArr in
            self.processResultAndValidateAllCBDSent(parameters: parametersArr)
        }
        
        // do a normal page view request:
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackPageView("some page view")
        }
        
        // valiadate that the CDB properties are NOT resent:
        // (This test uses a configuration with a cdbUpdateInterval of 1 day. So the CDB properties should not be resent with a page view request after some seconds.)
        doURLSendTestCheck() {parametersArr in
            self.processResultAndValidateNoCBDSent(parameters: parametersArr)
        }
    }
    
    
    /// Test to make sure that the CDB properties are resent after the cdbUpdateInterval has passed
    func testCDB2(){
        
        // do a CDB tracking request:
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackCDB(crossDeviceProperties)
        }
        
        // validate that all CDB properties were sent:
        doURLSendTestCheck() {parametersArr in
            self.processResultAndValidateAllCBDSent(parameters: parametersArr)
        }
        
        // do a normal page view request:
        doURLSendTestAction() {
            WebtrekkTracking.instance().trackPageView("some page view")
        }
        
        sleep(1)
        
        // valiadate that the CDB properties ARE resent:
        // (This test uses a configuration with a cdbUpdateInterval of 1 second. So the CDB properties should be resent with a page view request after some seconds.)
        doURLSendTestCheck() {parametersArr in
            self.processResultAndValidateAllCBDSent(parameters: parametersArr)
        }
    }
    
    
    
    ///
    /// check the result of a request and validate that all CDB properties are sent
    ///
    private func processResultAndValidateAllCBDSent(parameters: [String:String]) {
        validate("Elmo|Monster|90210|SesameStreet|5", is: parameters["cdb5"], "md5")
        validate("12345", is: parameters["cdb7"])
        validate("mail@test.de", is: parameters["cdb1"], "md5")
        validate("mail@test.de", is: parameters["cdb2"], "md256")
        validate("facebookId123", is: parameters["cdb10"], "sha256")
        validate("googlePlusId123", is: parameters["cdb12"], "sha256")
        validate("iOSId123", is: parameters["cdb8"])
        validate("linkedInId123", is: parameters["cdb13"], "sha256")
        validate("55512345", is: parameters["cdb3"], "md5")
        validate("55512345", is: parameters["cdb4"], "md256")
        validate("twitterId123", is: parameters["cdb11"], "sha256")
        validate("windowsId123", is: parameters["cdb9"])
        validate("three333", is: parameters["cdb53"])
        validate("eight888", is: parameters["cdb58"])
    }
    
    
    
    ///
    /// check the result of a request and validate that no CDB properties are sent
    ///
    private func processResultAndValidateNoCBDSent(parameters: [String:String]) {
        for i in 1...59 {
            expect(parameters["cdb"+String(i)]).to(beNil())
        }
    }
    
    
    private func validate(_ expectedValue: String, is cdbParam : String?, _ encode: String? = nil) {
        if encode == nil {
            expect(expectedValue.lowercased()).to(equal(cdbParam!.lowercased()))
        } else if encode == "sha256" {
            expect(expectedValue.lowercased().sha256().lowercased()).to(equal(cdbParam!.lowercased()))
        } else if encode == "md5" {
            expect(expectedValue.lowercased().md5().lowercased()).to(equal(cdbParam!.lowercased()))
        }
    }
}

