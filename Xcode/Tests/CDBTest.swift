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

class CDBTest: WTBaseTestNew {

    
    let parametersName: [String] = [
    //0, 1, 2, 3, 4, 5
    "email1", "email2", "email3", "email4", "emailmd", "emailsha",
    //6, 7, 8, 9, 10, 11, 12
    "phone1", "phone2", "phone3", "phone4","phone5", "phonemd", "phonesha",
    //13, 14, 15, 16
    "address1", "address2", "address3", "address4",
    //17, 18, 19, 20
    "address5", "address6", "address7", "address8",
    //21, 22
    "addressmd", "addresssha",
    //23, 24, 25, 26
    "androidID", "iosID", "WinID", "facebookID",
    //27, 28, 29, 30
    "TwitterID", "GooglePludID", "LinkedID", "custom1",
    //31
    "custom29"
    ]
    
    let parametersValue: [String] = [
    "test@tester.com", "TEST@TESTER.COM",  "Test@Tester.com", " Test@Tester.com ", "EF8CA1C0FF7D2E34DC0953D4222655B8", "1F9E575AD4234C30A81D30C70AFFD4BBA7B0D57D8E8607AD255496863D72C8BB",
    "01799586148", "+49179 9586148", "+49 179/9586148", "00 179/9586148", "0179 95 86 148", "6AF3CC537AB15FFB500167AF24D2B9D6", "629D99E8350B704511F8FE6506C38888C0749DACC0F091D7F8914CDD6B5B7862",
    "stephan|guenther|10115|teststrasse|7", "Stephan|Guenther|10115|Teststrasse|7", "Stephan|Günther|10115|Teststraße|7", "Stephan|Günther|10115|Teststr|7",
    "Stephan|Günther|10115|Teststr.|7", "Stephan|Günther|10115|Teststr. |7", " Stephan | Günther | 10 115 | Teststr. | 7 ", " Ste-phan | Günt_her | 10 1 15 | Test - str. | 7 ",
    "756E1FD66E46D930707ACD1B2D2DCC14", "6E65555EA5D3C707EF3E7BBC6A7E09D33C23DD2E23C36D6750B25BF86EFDF843",
    "ABC123DEF456", "ABC123DEF456", "ABC123DEF456", "100001603870661",
    "333887969", "103942815740852792445", "1R2RtA", "custom1Value",
    "custom29Value"
    ]
    
    //sha256 or original value
    let firstOrSha256KeyName: [String?] = [
    "cdb2", "cdb2", "cdb2", "cdb2", nil, "cdb2",
    "cdb4", "cdb4", "cdb4", "cdb4", "cdb4", nil, "cdb4",
    "cdb6", "cdb6", "cdb6", "cdb6",
    "cdb6", "cdb6", "cdb6", "cdb6",
    /*
     "cdb6", "cdb6","cdb6","cdb6",
     "cdb6", "cdb6","cdb6","cdb6",
     */
    nil, "cdb6",
    "cdb7", "cdb8", "cdb9", "cdb10",
    "cdb11", "cdb12", "cdb13", "cdb51",
    "cdb79"
    ]
    
    let mdKeyName: [String?] = [
    "cdb1", "cdb1", "cdb1", "cdb1", "cdb1", nil,
    "cdb3", "cdb3", "cdb3", "cdb3", "cdb3", "cdb3", nil,
    "cdb5", "cdb5", "cdb5", "cdb5",
    "cdb5", "cdb5", "cdb5", "cdb5",
    /*
     "cdb5", "cd5","cdb5","cdb5",
     "cdb5", "cd5","cdb5","cdb5",
     */
    "cdb5", nil,
    nil, nil, nil, nil,
    nil, nil, nil, nil,
    nil
    ]
    
    let firstOrSha256Value: [String?] = [
    "1f9e575ad4234c30a81d30c70affd4bba7b0d57d8e8607ad255496863d72c8bb", "1f9e575ad4234c30a81d30c70affd4bba7b0d57d8e8607ad255496863d72c8bb","1f9e575ad4234c30a81d30c70affd4bba7b0d57d8e8607ad255496863d72c8bb","1f9e575ad4234c30a81d30c70affd4bba7b0d57d8e8607ad255496863d72c8bb", nil, "1f9e575ad4234c30a81d30c70affd4bba7b0d57d8e8607ad255496863d72c8bb",
    "629d99e8350b704511f8fe6506c38888c0749dacc0f091d7f8914cdd6b5b7862", "27e75156a4134c75a019efcb7f899d62fb23d300667a79289fd4a11c4bcdbf87", "27e75156a4134c75a019efcb7f899d62fb23d300667a79289fd4a11c4bcdbf87", "6497ae00a154a09fc6b39c9e4c4ba6f64885e8279d587b66626fec44e8cc468c", "629d99e8350b704511f8fe6506c38888c0749dacc0f091d7f8914cdd6b5b7862",nil, "629d99e8350b704511f8fe6506c38888c0749dacc0f091d7f8914cdd6b5b7862",
    "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843",
    "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843", "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843",
    nil, "6e65555ea5d3c707ef3e7bbc6a7e09d33c23dd2e23c36d6750b25bf86efdf843",
    "abc123def456", "abc123def456", "abc123def456", "574852115fa603e477907c4284f5a45d92f3194a759f33b2d66f72309cc7ba07",
    "8182771b8680ca5bd979b339f3e3c1416342c3ea62133819c76c71aebaa38efb", "af3e9f1b964c6a377ba4ad61a37a84f5ba527ffd7b014515885217919c900ba6", "44a6998e43e432440de3b0045c278664b62fa9e77b32b12937561c67d385a732", "custom1Value",
    "custom29Value"
    ]
    
    let mdFieldValue: [String?] = [
    "ef8ca1c0ff7d2e34dc0953d4222655b8", "ef8ca1c0ff7d2e34dc0953d4222655b8", "ef8ca1c0ff7d2e34dc0953d4222655b8", "ef8ca1c0ff7d2e34dc0953d4222655b8","ef8ca1c0ff7d2e34dc0953d4222655b8", nil,
    "6af3cc537ab15ffb500167af24d2b9d6", "15a7498681d67ecc0b9c62c0087a9faa", "15a7498681d67ecc0b9c62c0087a9faa", "03f5113c45423448356b1c1c5a3e0027", "6af3cc537ab15ffb500167af24d2b9d6","6af3cc537ab15ffb500167af24d2b9d6", nil,
    "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14",
    "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14", "756e1fd66e46d930707acd1b2d2dcc14",
    "756e1fd66e46d930707acd1b2d2dcc14", nil,
    nil, nil, nil, nil,
    nil, nil, nil, nil,
    nil
    ]
    
    
    let cycleTestArr: [[Int]]  = [[0,6,13,23,24,25,26,27,28,29],
    [1, 7, 14], [2, 8, 15],  [3, 9, 16], [4, 5, 10, 17],
    [11, 12, 18], [19], [20], [21, 22], [30, 31]];
    
    
    
    
    func testCDB(){
        
        for cycle in 0...9 {
        
            doURLSendTestAction(){
                self.doTest(cycle)
            }
            doURLSendTestCheck(){parametersArr in
                self.processResult(cycle, parameters: parametersArr)
            }
        }

    }
    
    private func doTest(_ cycle: Int){
        if (cycle == 0){
            self.log(text: "Start CDB test -------------")
        }
        self.log(text: "Start test cycle \(cycle)---------------------")
        
        let track = WebtrekkTracking.instance()
        
        expect(track).notTo(beNil())
        
        switch cycle {
        case 0:
            track.trackCDB(CrossDeviceProperties(
                address: .plain(convertStringToAddress(parametersValue[cycleTestArr[cycle][2]])),
                androidId: parametersValue[cycleTestArr[cycle][3]],
                emailAddress: .plain(parametersValue[cycleTestArr[cycle][0]]),
                facebookId: parametersValue[cycleTestArr[cycle][6]],
                googlePlusId: parametersValue[cycleTestArr[cycle][8]],
                iosId: parametersValue[cycleTestArr[cycle][4]],
                linkedInId: parametersValue[cycleTestArr[cycle][9]],
                phoneNumber: .plain(parametersValue[cycleTestArr[cycle][1]]),
                twitterId: parametersValue[cycleTestArr[cycle][7]],
                windowsId: parametersValue[cycleTestArr[cycle][5]]
            ))
        case 1, 2, 3:
            track.trackCDB(CrossDeviceProperties(
                address: .plain(convertStringToAddress(parametersValue[cycleTestArr[cycle][2]])),
                emailAddress: .plain(parametersValue[cycleTestArr[cycle][0]]),
                phoneNumber: .plain(parametersValue[cycleTestArr[cycle][1]])
            ))
        case 4:
            track.trackCDB(CrossDeviceProperties(
            address: .plain(convertStringToAddress(parametersValue[cycleTestArr[cycle][3]])),
            emailAddress: .hashed(md5: parametersValue[cycleTestArr[cycle][0]], sha256: parametersValue[cycleTestArr[cycle][1]]),
            phoneNumber: .plain(parametersValue[cycleTestArr[cycle][2]])
            ))
        case 5:
            track.trackCDB(CrossDeviceProperties(
            address: .plain(convertStringToAddress(parametersValue[cycleTestArr[cycle][2]])),
            phoneNumber: .hashed(md5: parametersValue[cycleTestArr[cycle][0]], sha256: parametersValue[cycleTestArr[cycle][1]])
            ))
        case 6,7:
            track.trackCDB(CrossDeviceProperties(
            address: .plain(convertStringToAddress(parametersValue[cycleTestArr[cycle][0]]))
            ))
        case 8:
            track.trackCDB(CrossDeviceProperties(
             address: .hashed(md5: parametersValue[cycleTestArr[cycle][0]], sha256: parametersValue[cycleTestArr[cycle][1]])
             ))
        // Making sure that custom CDB parameters are tracked (in this case custom parameter 1 an 29):
        case 9:
            let custom: [Int: String]? = [1: parametersValue[cycleTestArr[cycle][0]], 29: parametersValue[cycleTestArr[cycle][1]]]
            track.trackCDB(CrossDeviceProperties(
                custom: custom
            ))
        default:
            self.log(text: "Incorrect CDB case")
        }
        
    }
    
    private func processResult (_ cycle: Int, parameters: [String:String]){

        for index in cycleTestArr[cycle] {
            
            let parName = parametersName[index];
            let parValue = parametersValue[index];
            let firstKey = firstOrSha256KeyName[index];
            let firstValue = firstOrSha256Value[index]?.lowercased();
            let mdKey = mdKeyName[index];
            let mdValue = mdFieldValue[index]?.lowercased();
            
            self.log(text: "test " + parName + " value:" + parValue+"\n")
            
            if let key = firstKey {
                expect(firstValue).to(equal(parameters[key]?.lowercased()), description: "cycle: \(cycle) key:\(key) index: \(index). expected: \(firstValue.simpleDescription) actual:\(parameters[key].simpleDescription)")
            }
            
            if let key = mdKey {
                expect(mdValue).to(equal(parameters[key]?.lowercased()), description: "cycle: \(cycle) key:\(key) index: \(index). expected: \(mdValue.simpleDescription) actual:\(parameters[key].simpleDescription)")
            }
        }
    }
    
    private func convertStringToAddress(_ value: String) -> CrossDeviceProperties.Address {
        let addressConponents = value.split(separator: "|")
        return CrossDeviceProperties.Address(firstName: String(addressConponents[0]),
            lastName: String(addressConponents[1]), street: String(addressConponents[3]),
            streetNumber: String(addressConponents[4]), zipCode: String(addressConponents[2]))
    }
}
