// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import Foundation
import GameplayKit
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

class GenericNodeTests: AKTestCase {
    func nodeRandomizedTest(md5: String, factory: () -> Node, audition: Bool = false) {
        // We want determinism.
        let rng = GKMersenneTwisterRandomSource(seed: 0)

        let duration = 10
        let engine = Engine()
        var bigBuffer: AVAudioPCMBuffer?

        for _ in 0 ..< duration {
            let node = factory()
            engine.output = node

            let audio = engine.startTest(totalDuration: 1.0)
            setParams(node: node, rng: rng)
            audio.append(engine.render(duration: 1.0))

            if bigBuffer == nil {
                bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))
            }

            bigBuffer?.append(audio)
        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition { bigBuffer!.audition() }

        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    /// Test the parameters of a node.
    ///
    /// Because of platform differences we pass in an array of possible checksums.
    func nodeParameterTest(md5s: [String], factory: (Node) -> Node, audition: Bool = false) {
        let sampler = Sampler()
        sampler.play(url: .testAudio)
        let node = factory(sampler)

        let duration = node.parameters.count + 1

        let engine = Engine()
        var bigBuffer: AVAudioPCMBuffer?

        engine.output = node

        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }

        for i in 0 ..< node.parameters.count {
            let node = factory(sampler)
            engine.output = node

            let param = node.parameters[i]

            param.value = param.def.range.lowerBound
            param.ramp(to: param.def.range.upperBound, duration: 1)

            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            bigBuffer?.append(audio)
        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }
        XCTAssertTrue(md5s.contains(bigBuffer!.md5), "\(node)\nFAILEDMD5 \(bigBuffer!.md5)")
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testGenerators() {
        nodeParameterTest(md5s: ["885d882c758552e08a214b661eb128e4"], factory: { _ in let osc = Oscillator(waveform: Table(.square)); return osc })
        nodeParameterTest(md5s: ["569c8b32aa826ba22f62d8b682dc4ca4"], factory: { _ in let osc = Oscillator(waveform: Table(.triangle)); return osc })
        nodeParameterTest(md5s: ["d0a155478e77465653beccb31d3d45b7"], factory: { _ in let osc = Oscillator(waveform: Table(.triangle), amplitude: 0.1); return osc })
    }

    func testEffects() {
        nodeParameterTest(md5s: ["dec105c6e2e44556608c9f393e205c1e"], factory: { input in Delay(input, time: 0.01) })
        nodeParameterTest(md5s: ["3979c710eff8e12f0c3f535987624fde", "2bca99c77cf6ed19cca0cd276e204fee"], factory: { input in Distortion(input) })
        nodeParameterTest(md5s: ["7578e739da5c7b433bee6ebbad8d92f5"], factory: { input in DynamicsProcessor(input) })
        nodeParameterTest(md5s: ["d65f43bda68342d9a53a5e9eda7ad36d"], factory: { input in PeakLimiter(input) })
        #if os(macOS)
        nodeParameterTest(md5s: ["28d2cb7a5c1e369ca66efa8931d31d4d",
                                 "20215ab1ecb1943ca15d98e239018f25",
                                 "a131e348045438d2bef6d588c3a4e7a1"],
                          factory: { player in Reverb(player) })
        #endif
    }

    func testFilters() {
        nodeParameterTest(md5s: ["85d7fbd22c14dc7cc8d3954ebafd0407"], factory: { input in BandPassFilter(input) })
        nodeParameterTest(md5s: ["befc21e17a65f32169c8b0efb15ea75c"], factory: { input in HighPassFilter(input) })
        nodeParameterTest(md5s: ["69926231aedb80c4bd9ad8c27e2738b8"], factory: { input in HighShelfFilter(input) })
        nodeParameterTest(md5s: ["aa3f867e12cf44b80d8142ebd0dc00a5"], factory: { input in LowPassFilter(input) })
        nodeParameterTest(md5s: ["8bcb9c497515412afae7ae3bd2cc7b62"], factory: { input in LowShelfFilter(input) })
    }
}
