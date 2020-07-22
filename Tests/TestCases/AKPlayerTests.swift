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

    func testBasic() {

        guard let audioFileURL = Bundle.main.url(forResource: "sinechirp", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

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

        guard let audioFileURL = Bundle.main.url(forResource: "sinechirp", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

        guard let player = AKPlayer(url: audioFileURL) else {
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
        }

        output = player
        player.fade.inTime = 0.2

        //auditionTest()
        AKTestMD5("70ace673dd8972652d490bacae67631e")
    }

    func testFadeInOut() {

        let bundle = Bundle(for: AKPlayerTests.self)

        guard let audioFileURL = bundle.url(forResource: "PinkNoise", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

        guard let player = AKPlayer(url: audioFileURL) else {
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
        }

        output = player
        player.fade.inTime = 1.0
        player.fade.outTime = 1.0
        player.gain = 0.2
        player.endTime = 5
        duration = 5

        // auditionTest()
        AKTestMD5("aaf7406741627df074bf050839c269bb")
    }

    func testFadeOut() {

        let bundle = Bundle(for: AKPlayerTests.self)

        guard let audioFileURL = bundle.url(forResource: "PinkNoise", withExtension: "wav") else {
            XCTFail("Couldn't find audio file.")
            return
        }

        guard let player = AKPlayer(url: audioFileURL) else {
            XCTFail("Couldn't load audio file.")
            return
        }

        afterStart = {
            player.play()
            player.fadeOut(with: 5)
        }

        output = player
        player.gain = 0.2
        player.endTime = 5
        duration = 5

        auditionTest()
        // AKTestMD5("aaf7406741627df074bf050839c269bb")
    }

}
