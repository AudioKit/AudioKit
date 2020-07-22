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
            XCTFail("Couldn't load audio file.")
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
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
        }

        output = player
        player.fade.inTime = 0.3

        //auditionTest()
        AKTestMD5("2f21e7448012c1c8585f216a235741f2")
    }

}
