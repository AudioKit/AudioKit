// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio
import XCTest

class DistortionTests: AKTestCase {
    func testDefault() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = Distortion(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPresetChange() {
        let engine = AudioEngine()
        let sampler = Sampler()
        let distortion = Distortion(sampler)
        distortion.loadFactoryPreset(.drumsBitBrush)
        engine.output = distortion
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
