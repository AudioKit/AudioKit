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

func generatorNodeRandomizedTest(factory: ()->Node) -> AVAudioPCMBuffer {

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

    return bigBuffer!

}


class GenericGeneratorTests: XCTestCase {

    func generatorNodeParameterTest(md5: String, factory: ()->Node) {

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

        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testGenerators() {
        generatorNodeParameterTest(md5: "b9625eb52a6e6dfd7faaeec6c5048c12", factory: { Oscillator(waveform: Table(.triangle)) })
        generatorNodeParameterTest(md5: "aa55d9609190e0ec3c7a87eac1cfedba", factory: { FMOscillator(waveform: Table(.triangle)) })
        generatorNodeParameterTest(md5: "7b629793ed707a314b8a8e0ec77d1aff", factory: { MorphingOscillator(waveformArray: waveforms) })
        generatorNodeParameterTest(md5: "77f3fa06092fe331cbbb98eefb729786", factory: { WhiteNoise() })
        generatorNodeParameterTest(md5: "4096cd1e94daf68121d28b0613ef3bee", factory: { PinkNoise() })
        generatorNodeParameterTest(md5: "404e9aab0cf98d0485e154146b1c0862", factory: { BrownianNoise() })
    }
}
