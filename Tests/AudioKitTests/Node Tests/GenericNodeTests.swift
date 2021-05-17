// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@testable import AudioKit
import GameplayKit
import AVFoundation
import XCTest

func setParams(node: Node, rng: GKRandomSource) {

    for param in node.parameters {
        let def = param.def
        let size = def.range.upperBound - def.range.lowerBound
        let value = rng.nextUniform() * size + def.range.lowerBound
        print("setting parameter \(def.name) to \(value)")
        param.value = value
    }

}

class GenericNodeTests: XCTestCase {

    func nodeRandomizedTest(md5: String, factory: ()->Node, audition: Bool = false) {

        // We want determinism.
        let rng = GKMersenneTwisterRandomSource(seed: 0)

        let duration = 10
        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer? = nil

        for _ in 0 ..< duration {

            let node = factory()
            engine.output = node

            node.start()

            let audio = engine.startTest(totalDuration: 1.0)
            setParams(node: node, rng: rng)
            audio.append(engine.render(duration: 1.0))

            if bigBuffer == nil {
                bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength*UInt32(duration))
            }

            bigBuffer?.append(audio)

        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }

        XCTAssertEqual(bigBuffer!.md5, md5)

    }

    func nodeParameterTest(md5: String, factory: ()->Node, audition: Bool = false) {

        let duration = factory().parameters.count

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer? = nil

        for i in 0 ..< duration {

            let node = factory()
            engine.output = node

            let param = node.parameters[i]

            node.start()

            param.value = param.def.range.lowerBound
            param.ramp(to: param.def.range.upperBound, duration: 1)

            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            if bigBuffer == nil {
                bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength*UInt32(duration))
            }

            bigBuffer?.append(audio)

        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }

        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testGenerators() {
        nodeParameterTest(md5: "404e9aab0cf98d0485e154146b1c0862", factory: { BrownianNoise() })
        nodeParameterTest(md5: "efe8734db6ad9e7f81b551efb0d20ab2", factory: { DynamicOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "aa55d9609190e0ec3c7a87eac1cfedba", factory: { FMOscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "7b629793ed707a314b8a8e0ec77d1aff", factory: { MorphingOscillator(waveformArray: waveforms) })
        nodeParameterTest(md5: "b9625eb52a6e6dfd7faaeec6c5048c12", factory: { Oscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "59fbb6d1b42d3b2d573a18ae8b9cf0d0", factory: { PhaseDistortionOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "f8a6be7c394d88b9d13a208c66efd5f0", factory: { PWMOscillator() })
        nodeParameterTest(md5: "4096cd1e94daf68121d28b0613ef3bee", factory: { PinkNoise() })
        nodeParameterTest(md5: "000afd6c1acb3288df1e526e7df283f3", factory: { VocalTract() })
        nodeParameterTest(md5: "77f3fa06092fe331cbbb98eefb729786", factory: { WhiteNoise() })
        
        nodeRandomizedTest(md5: "999a7c4d39edf55550b2b4ef01ae1860", factory: { BrownianNoise() })
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "1075bfbdd871ae8fd4b9953b93a48438", factory: { AutoPanner(input, waveform: Table(.triangle)) })
        nodeParameterTest(md5: "4a63f96ea20794d24273a43b4d9f01ac", factory: { AutoWah(input) })
        nodeParameterTest(md5: "f893b3a2e1334c34d1fa6704b29cb35b", factory: { CostelloReverb(input) })
    }
}
