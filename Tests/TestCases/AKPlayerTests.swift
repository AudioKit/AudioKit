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
        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
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

        //auditionTest()
        AKTestMD5("90ef5318b34510ef7c81f957046c06d6")
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

        // auditionTest()
        AKTestMD5("bbb8d6a862cf8974e0b3ec399a94bba0")
    }

    func testDelay() {

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
            player.play(at: AVAudioTime(sampleTime: 2 * 44100, atRate: 44100))
        }

        output = player
        player.fade.inTime = 1.0
        player.fade.outTime = 1.0
        player.gain = 0.2
        player.endTime = 3
        duration = 5

        // auditionTest()
        AKTestMD5("3316cbd51ca69099e018280912bd02f1")
    }

}
