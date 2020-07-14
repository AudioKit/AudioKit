// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBoosterTests: AKTestCase {

    func testDefault() {
        output = AKBooster(input)
        AKTestNoEffect()
    }

    func testBypass() {
        let booster = AKBooster(input, gain: 2.0)
        booster.bypass()
        output = booster
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKBooster(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testParameters2() {
        output = AKBooster(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }

    #if os(macOS)
    func testRamp() {
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let url = desktop.appendingPathComponent("TestOutput.aif")
        let settings: [String: Any] = [AVSampleRateKey: 44_100.0, AVNumberOfChannelsKey: 2]
        let audioFile = try! AVAudioFile(forWriting: url, settings: settings)
        let osc = AKOscillator()
        let booster = AKBooster(osc, gain: 1.0)
        booster.rampDuration = 1
        booster.leftGain = 0.0
        booster.rightGain = 0.0
        osc.connect(to: booster)
        AKManager.output = booster
        try! AKManager.renderToFile(audioFile, duration: 4, prerender: {
            osc.start()
        })
    }
    #endif

}
