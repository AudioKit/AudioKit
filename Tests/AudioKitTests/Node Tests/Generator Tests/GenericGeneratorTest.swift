// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@testable import AudioKit
import GameplayKit
import AVFoundation

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

func generatorNodeParameterTest(factory: ()->Node) -> AVAudioPCMBuffer {

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

    return bigBuffer!
}
