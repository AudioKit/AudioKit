// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKVocalTractTests: AKTestCase {
    var vocalTract = AKVocalTract()

    override func setUp() {
        afterStart = { self.vocalTract.start() }
        vocalTract.rampDuration = 0
        vocalTract.start()
    }

    func testDefault() {
        engine.output = vocalTract
        AKTest()
    }

    func testFrequency() {
        vocalTract.frequency = 444.5
        engine.output = vocalTract
        AKTest()
    }

    func testNasality() {
        vocalTract.nasality = 0.6
        engine.output = vocalTract
        AKTest()
    }

    func testTenseness() {
        vocalTract.tenseness = 0.5
        engine.output = vocalTract
        AKTest()
    }

    func testTongueDiameter() {
        vocalTract.tongueDiameter = 0.4
        engine.output = vocalTract
        AKTest()
    }

    func testTonguePosition() {
        vocalTract.tonguePosition = 0.3
        engine.output = vocalTract
        AKTest()
    }

    func testParametersSetAfterInit() {
        vocalTract.frequency = 234.5
        vocalTract.tonguePosition = 0.3
        vocalTract.tongueDiameter = 0.4
        vocalTract.tenseness = 0.5
        vocalTract.nasality = 0.6
        engine.output = vocalTract
        AKTest()
    }

    func testParametersSetOnInit() {
        vocalTract = AKVocalTract(frequency: 234.5,
                                  tonguePosition: 0.3,
                                  tongueDiameter: 0.4,
                                  tenseness: 0.5,
                                  nasality: 0.6)
        engine.output = vocalTract
        AKTest()
    }

}
