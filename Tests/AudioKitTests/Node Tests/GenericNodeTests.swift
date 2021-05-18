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

        if audition { bigBuffer!.audition() }

        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    func nodeParameterTest(md5: String, factory: ()->Node, audition: Bool = false) {

        let duration = factory().parameters.count + 1

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer? = nil

        let node = factory()
        engine.output = node
        
        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }
        
        for i in 0 ..< factory().parameters.count {

            let node = factory()
            engine.output = node

            let param = node.parameters[i]

            node.start()

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
        XCTAssertEqual(bigBuffer!.md5, md5)
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testGenerators() {
        nodeParameterTest(md5: "91982383233dc367491b40704c803bb8", factory: { BrownianNoise() })
        nodeParameterTest(md5: "57932788e602736da3895d8dcbb1b4a7", factory: { DynamicOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "d9f942578b818e5028d7040a12721f97", factory: { FMOscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "01072e25418a79c82b58d4bfe69e5375", factory: { MorphingOscillator(waveformArray: waveforms) })
        nodeParameterTest(md5: "ecdc68d433f767140b7f5f61b343ac21", factory: { Oscillator(waveform: Table(.triangle)) })
        nodeParameterTest(md5: "0ef5939e306673edd6809f030e28ce16", factory: { PhaseDistortionOscillator(waveform: Table(.square)) })
        nodeParameterTest(md5: "5d7c77114f863ec66aeffaf1243ae9c8", factory: { PWMOscillator() })
        nodeParameterTest(md5: "afdce4990f72e668f088765fabc90f0a", factory: { PinkNoise() })
        nodeParameterTest(md5: "25da4d13733e7c50e3b9706e028c452d", factory: { VocalTract() })
        nodeParameterTest(md5: "6fc97b719ed8138c53464db8f09f937e", factory: { WhiteNoise() })
        
        nodeRandomizedTest(md5: "999a7c4d39edf55550b2b4ef01ae1860", factory: { BrownianNoise() })
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "b67881dcf5c17fed56a9997ccc0a5161", factory: { AutoPanner(input, waveform: Table(.triangle)) })
        nodeParameterTest(md5: "d35074473678f32b4ba7c54e635b2766", factory: { AutoWah(input) })
        nodeParameterTest(md5: "55d5e818c9e8e3d6bfe1b029b6857ed3", factory: { BitCrusher(input) })
        nodeParameterTest(md5: "ffd48f502e2a5b2a7027d42b917a6667", factory: { ChowningReverb(input) })
        nodeParameterTest(md5: "56e76b5bd1d59d77ad4bd670f605f191", factory: { Clipper(input) })
        nodeParameterTest(md5: "c9ab35b7818db6a9af4edfbe2cb83927", factory: { CombFilterReverb(input) })
        nodeParameterTest(md5: "6162703525d7213e58c0b7e6decda293", factory: { Compressor(input) })
        nodeParameterTest(md5: "1d47a6a4a24667064b747cd6571d0874", factory: { CostelloReverb(input) })
        nodeParameterTest(md5: "6d17509eee0059105454f3cad4499586", factory: { DCBlock(input) })
        nodeParameterTest(md5: "55d7b2312d921aacf87d92c81bcbc806", factory: { Decimator(input) })
        nodeParameterTest(md5: "768665e4bad0372b7cdcc8be6040621e", factory: { Delay(input) })
        nodeParameterTest(md5: "f8fcb22a49489da6fb2d7d12cab10ce8", factory: { DiodeClipper(input) })
        nodeParameterTest(md5: "2b0db813cce8ff7f2180d7a820737000", factory: { Distortion(input) })
        nodeParameterTest(md5: "a245e060a95fa63f70f01633eb00db0b", factory: { DynamicRangeCompressor(input) })
        nodeParameterTest(md5: "3fe8139c1ce37fc14dfba77138345510", factory: { DynaRageCompressor(input) })
        nodeParameterTest(md5: "6173d108ae0fcede9e7f1f0b122622a9", factory: { Flanger(input) })
        nodeParameterTest(md5: "b2eac657e060927cd0b3bfd74817c99e", factory: { FlatFrequencyResponseReverb(input) })
        nodeParameterTest(md5: "a6c3c2cdc02e77c1d71bcab22b70982c", factory: { Panner(input) })
        nodeParameterTest(md5: "dc2fcab5eeb367e93b3767a7f84f7491", factory: { PeakLimiter(input) })
        nodeParameterTest(md5: "95ba7a1fbd8c85c129999d20a0653dfe", factory: { PitchShifter(input) })
        nodeParameterTest(md5: "99fedd785937d8e1d0e201e15124b19c", factory: { Reverb(input) })
        nodeParameterTest(md5: "d68057bc230214c09607509652dd8994", factory: { RhinoGuitarProcessor(input) })
        nodeParameterTest(md5: "547cc8833929d40042a0a00566cc032f", factory: { RingModulator(input) })
        nodeParameterTest(md5: "addc1655615279c0e02ae9f9db7b79b8", factory: { StereoDelay(input) })
        nodeParameterTest(md5: "2965f1e7d77deddb213a1ad56060e6e3", factory: { StereoFieldLimiter(input) })
        nodeParameterTest(md5: "56ce31a64d0c7488e814cd16e09ea378", factory: { StringResonator(input) })
        nodeParameterTest(md5: "7ce66baf0b5a272dc83db83f443bd1d8", factory: { TanhDistortion(input) })
        nodeParameterTest(md5: "17b152691ddaca9a74a5ab086db0e546", factory: { VariableDelay(input) })
        nodeParameterTest(md5: "78f088f0a48ab37c3d5fcfca9c9a8365", factory: { ZitaReverb(input) })
    }
    
    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "e21144303552ef8ba518582788c3ea1f", factory: { BandPassButterworthFilter(input) })
        nodeParameterTest(md5: "cbc23ff6ee40c12b0348866402d9fac3", factory: { BandRejectButterworthFilter(input) })
        nodeParameterTest(md5: "8eca17f8e436de978afc7250edd765fe", factory: { EqualizerFilter(input) })
        nodeParameterTest(md5: "433c45f0211948ecaa8bfd404963af7b", factory: { FormantFilter(input) })
        nodeParameterTest(md5: "9b38c130c6faf04b5b168d6979557a3f", factory: { HighPassButterworthFilter(input) })
        nodeParameterTest(md5: "4120a8fefb4efe8f455bc8c001ab1538", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "5aaeb38a15503c162334f0ec1bfacfcd", factory: { HighShelfFilter(input) })
        nodeParameterTest(md5: "b4c47d9ad07ccf556accb05336c52469", factory: { HighShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "6790ba0e808cc8e49f1a609b05b5c490", factory: { KorgLowPassFilter(input) })
        nodeParameterTest(md5: "ce2bd006a13317b11a460a12ad343835", factory: { LowPassButterworthFilter(input) })
        nodeParameterTest(md5: "aeec895e45341249b7fc23ea688dfba8", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "2f81a7a8c9325863b4afa312ca066ed8", factory: { LowShelfFilter(input) })
        nodeParameterTest(md5: "2f7e88b1835845342b0c8cca9930cb5c", factory: { LowShelfParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "0db12817a5def3a82d0d28fc0c3f8ab9", factory: { ModalResonanceFilter(input) })
        nodeParameterTest(md5: "535192bcc8107d22dae9273f284b1bc5", factory: { MoogLadder(input) })
        nodeParameterTest(md5: "3a0b95902029e33a5b80b3a3baf6f8a7", factory: { PeakingParametricEqualizerFilter(input) })
        nodeParameterTest(md5: "06ebb0f4defb20ef2213ec60acf60620", factory: { ResonantFilter(input) })
        nodeParameterTest(md5: "c0f44f67e4ba3f3265fb536109126eb4", factory: { RolandTB303Filter(input) })
        nodeParameterTest(md5: "44273d78d701be87ec9613ace6a179cd", factory: { ThreePoleLowpassFilter(input) })
        nodeParameterTest(md5: "84c3dcb52f76610e0c0ed9b567248fa1", factory: { ToneComplementFilter(input) })
        nodeParameterTest(md5: "f4b3774bdc83f2220b33ed7de360a184", factory: { ToneFilter(input) })

    }
}
