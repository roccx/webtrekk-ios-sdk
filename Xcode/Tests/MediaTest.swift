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
    
    var mainViewController: ViewController!
    
    override func getConfigName() -> String?{
        return String("webtrekk_config_no_completely_autoTrack")
    }

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
    #if !os(tvOS)
    func testAVPlayer(){
        
        if self.mainViewController == nil {
            self.mainViewController = ViewController()
        }
        
        guard let videoUrl = Bundle.main.url(forResource: "Video", withExtension: "mp4") else {
            return
        }
        
        let player = AVPlayer(url: videoUrl)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        self.mainViewController.beginAppearanceTransition(true, animated: false)
        self.mainViewController.endAppearanceTransition()

        
        playerLayer.frame = self.mainViewController.view.bounds
        self.mainViewController.view.layer.addSublayer(playerLayer)
        
        let tracker = WebtrekkTracking.instance()
        
        tracker["Key2"] = "KeyValueFor_Key2"
        
        var requestNumber: Int = 1
        enum TestPhase { case _init, play, pause, pos, finish}
        var platPhase: TestPhase = ._init
        
        
        self.httpTester.removeStub()
        self.httpTester.addNormalStub(){query in
            let parametersArr = self.httpTester.getReceivedURLParameters((query.url?.query!)!)
            
            expect(parametersArr["mg2"]).to(equal("KeyValueFor_Key2"))
            expect(parametersArr["p"]).to(contain("mediaPageName"))
            expect(parametersArr["mi"]).to(equal("mediaName"))
            expect(parametersArr["mg5"]).to(equal("5Value"))
            
            switch (platPhase, requestNumber){
            case (._init, 1):
                expect(parametersArr["mk"]).to(equal("init"))
                expect(parametersArr["mt1"]).to(equal("0"))
                expect(parametersArr["mt2"]).to(equal("0"))
            case (._init, 2):
                expect(parametersArr["mk"]).to(equal("play"))
                expect(parametersArr["mt1"]).to(equal("0"))
                expect(parametersArr["mt2"]).to(equal("135"))
            case (.pause, 3):
                expect(parametersArr["mt2"]).to(equal("135"))
                expect(Int(parametersArr["mt1"]!)).to(beGreaterThan(0))
                expect(parametersArr["mk"]).to(equal("pause"))
            case (.play, 4):
                expect(parametersArr["mt2"]).to(equal("135"))
                expect(Int(parametersArr["mt1"]!)).to(beGreaterThan(0))
                expect(parametersArr["mk"]).to(equal("play"))
            case (.pos, 5):
                expect(parametersArr["mt2"]).to(equal("135"))
                expect(Int(parametersArr["mt1"]!)).to(beGreaterThan(0))
                expect(parametersArr["mk"]).to(equal("pos"))
            case (.finish, 6):
                expect(parametersArr["mt2"]).to(equal("135"))
                expect(Int(parametersArr["mt1"]!)).to(beGreaterThan(0))
                expect(parametersArr["mk"]).to(equal("finish"))
            default:
                break;
            }
            
            requestNumber = requestNumber + 1
        }
        let meiaName = "mediaName"
        var mediaProperties = MediaProperties(name: meiaName)

        mediaProperties.groups = [5: .constant("5Value")]

        let _ = tracker.trackerForMedia("mediaName", pageName: "mediaPageName", automaticallyTrackingPlayer: player, mediaProperties: mediaProperties)
        
        
        // start play
        player.play()
        doSmartWait(sec: 3)
        // test pause
        platPhase = .pause
        player.rate = 0.0
        doSmartWait(sec: 3)
        // start play again quickly
        platPhase = .play
        player.rate = 4.0
        // wait to fix play state
        doSmartWait(sec: 4)
        platPhase = .pos
        //wait to fix pos state
        doSmartWait(sec: 30)
        platPhase = .finish
        // wait to fix finish
        doSmartWait(sec: 10)
        // finish test
        playerLayer.player = nil
    }
    #endif

}
