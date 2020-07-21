//
//  AKPlayerTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/21/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPlayerTests: AKTestCase {

    let audioFileURL = Bundle.main.url(forResource: "sinechirp", withExtension: "wav")!

    func testBasic() {

        guard let player = AKPlayer(url: audioFileURL) else {
            XCTFail()
            return
        }

        afterStart = {
            player.play()
        }

        output = player

        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
    }

    func testAutomation() {

        guard let player = AKPlayer(url: audioFileURL) else {
            XCTFail()
            return
        }

        afterStart = {
            player.play()
        }

        output = player

        player.fade.inTime = self.duration
        player.faderNode?.leftGain = 0
        player.faderNode?.rightGain = 0
        player.faderNode?.addAutomationPoint(value: 1.0, at: 0.0, rampDuration: self.duration)

        AKTestMD5("4ada6b1b67edc990324c041a22857acc")
    }

}
