// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@testable import AudioKit
import GameplayKit
import AVFoundation

func setParams(node: Node, rng: GKRandomSource) {

    let mirror = Mirror(reflecting: node)

    for child in mirror.children {
        if let param = child.value as? ParameterBase {
            let def = param.projectedValue.def
            let size = def.range.upperBound - def.range.lowerBound
            let value = rng.nextUniform() * size + def.range.lowerBound
            print("setting parameter \(def.name) to \(value)")
            param.projectedValue.value = value
        }
    }
}

func generatorNodeTest(factory: ()->Node) -> AVAudioPCMBuffer {

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

