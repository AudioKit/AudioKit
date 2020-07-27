//
//  AKPlayerTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/21/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPlayerTests: AKTestCase {
    func testBasic() {
        guard let url = Bundle.main.url(forResource: "sinechirp", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

        guard let player = AKPlayer(url: url) else {
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
        }

        output = player

        // auditionTest()
        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
    }

    func testFadeInOut() {
        let bundle = Bundle(for: AKPlayerTests.self)

        guard let url = bundle.url(forResource: "PinkNoise", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

        guard let player = AKPlayer(url: url) else {
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
        }

        output = player
        player.fade.inTime = 1.0
        player.fade.outTime = 1.0
        duration = player.duration

        // auditionTest()
        AKTestMD5("9c133a9288e33e574552c40e9dec5e48")
    }
}
