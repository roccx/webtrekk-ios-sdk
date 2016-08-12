//
//  MediaTest.swift
//  WebtrekkTest
//
//  Created by arsen.vartbaronov on 05/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
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
                    duration: NSTimeInterval(33.6),
                    groups: [20: "group20"],
                    position: NSTimeInterval(44.5),
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
            expect(parametersArr["x"]).notTo(beNil())
            expect(parametersArr["mut"]).to(equal("1"))
        }
    }

}
