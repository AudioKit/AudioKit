//
//  AKBooster2Tests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 11/22/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBooster2Tests: AKTestCase {

    func testDefault() {
        output = AKBooster2(input)
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKBooster2(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testParameters2() {
        output = AKBooster2(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }

  func testRamp() {
    let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let url = desktop.appendingPathComponent("TestOutput.aif")
    let settings: [String : Any] = [AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 2]
    let audioFile = try! AKAudioFile(forWriting: url, settings: settings)
    let osc = AKOscillator()
    let booster = AKBooster2(osc, gain: 1.0)
    booster.rampTime = 1
    booster.leftGain = 0.0
    booster.rightGain = 0.0
    osc.connect(to: booster)
    AudioKit.output = booster
    try! AudioKit.renderToFile(audioFile, seconds: 4, prerender: {
      osc.start()
    })
  }

}
