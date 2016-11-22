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

class MediaTest: WTBaseTestNew {

    func testMedia() {
        
        doURLSendTestAction(){
            let track = WebtrekkTracking.instance()
            
            track.trackMediaAction(MediaEvent(
                action: .play,
                mediaProperties: MediaProperties(
                    name: "mpName",
                    bandwidth: 22.2,
                    duration: TimeInterval(33.6),
                    groups: [20: "group20"],
                    position: TimeInterval(44.5),
                    soundIsMuted: true,
                    soundVolume: 9.9),
                pageName: "mediaPage"))
        }
        
        doURLSendTestCheck(){parametersArr in
            expect(parametersArr["p"]).to(contain("mediaPage"))
            expect(parametersArr["mk"]).to(equal("play"))
            expect(parametersArr["mt1"]).to(equal("44"))
            expect(parametersArr["mt2"]).to(equal("33"))
            expect(parametersArr["bw"]).to(equal("22"))
            expect(parametersArr["vol"]).to(equal("990"))
            expect(parametersArr["mg20"]).to(equal("group20"))
            expect(parametersArr["mi"]).to(equal("mpName"))
            expect(parametersArr["x"]).toNot(beNil())
            expect(parametersArr["mut"]).to(equal("1"))
        }
    }

}
