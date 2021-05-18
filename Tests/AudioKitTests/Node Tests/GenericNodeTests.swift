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
        nodeParameterTest(md5: "dc0b9cda4374c77307305ac0e6274526", factory: { BitCrusher(input) })
        nodeParameterTest(md5: "5dce42089c2cdfdc25af39026ea2fcf6", factory: { Clipper(input) })
        nodeParameterTest(md5: "d998be5c79d0f96513a698a5dfdda9f3", factory: { Compressor(input) })
        nodeParameterTest(md5: "f893b3a2e1334c34d1fa6704b29cb35b", factory: { CostelloReverb(input) })
    }
    
    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "25087938497d8c0bf5f38ea1f563612f", factory: { BandPassButterworthFilter(input) })
        nodeParameterTest(md5: "8e64777705cd5f8e3e88780abcc8c3a6", factory: { BandRejectButterworthFilter(input) })
        nodeParameterTest(md5: "ac25d953bf2dc1a16ab46ecc150b4158", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "cdb62e633e7a4ce6cc58aca1a2586bde", factory: { FormantFilter(input) })
        nodeParameterTest(md5: "f83fcc5a97ed48a43b0547ccb3403b00", factory: { HighPassButterworthFilter(input) })
        nodeParameterTest(md5: "2aa558acdf5d8f405f75a25f56ad57bf", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "b2417fe1f8b5e50f8a5edb828295a56d", factory: { HighShelfFilter(input) })
        nodeParameterTest(md5: "84c316c2c9a68b396b395715027e7655", factory: { HighShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "7af996d0eac52734b0eb91fe52a5acd0", factory: { KorgLowPassFilter(input) })
        nodeParameterTest(md5: "614d21e487bb7fae7085c34c15916449", factory: { LowPassButterworthFilter(input) })
        nodeParameterTest(md5: "22571d6861e9b938c956b3b0349c8824", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "294a562a44f5cf972543667de71a990e", factory: { LowShelfFilter(input) })
        nodeParameterTest(md5: "02ae0a77f57ed63bc2bd7ca9662b15d6", factory: { LowShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "1653597d53066533321351455644f07a", factory: { ModalResonanceFilter(input) })
        nodeParameterTest(md5: "3f11726b6b3a8002e3216e30f9a27893", factory: { MoogLadder(input) })
        nodeParameterTest(md5: "8777004f0ddcbcd025980fc56453ce00", factory: { PeakingParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "ea3c5cad1401b2e7a54a244ef11fe37d", factory: { ResonantFilter(input) })
        nodeParameterTest(md5: "ff6a59faaca20d7f07f0f1d02989e471", factory: { RolandTB303Filter(input) })
        nodeParameterTest(md5: "9511d8c2459250d4008d5e56ceabc743", factory: { ThreePoleLowpassFilter(input) })
        nodeParameterTest(md5: "12b4066b7ea32dd9ab1cac98bb827d12", factory: { ToneComplementFilter(input) })
        nodeParameterTest(md5: "e7265f68f6ce6480f915408b8e898b72", factory: { ToneFilter(input) })

    }
}
