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

    func nodeParameterTest(md5: String, factory: ()->Node, m1MD5: String = "", audition: Bool = false) {

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
        XCTAssertTrue([md5, m1MD5].contains(bigBuffer!.md5), "\(node) produced \(bigBuffer!.md5)")
    }

    let waveforms = [Table(.square), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testGenerators() {
        nodeParameterTest(md5: "ecdc68d433f767140b7f5f61b343ac21", factory: { Oscillator(waveform: Table(.triangle)) })
    }

    func testEffects() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        //nodeParameterTest(md5: "6162703525d7213e58c0b7e6decda293", factory: { Compressor(input) })
        nodeParameterTest(md5: "55d7b2312d921aacf87d92c81bcbc806", factory: { Decimator(input) })
        nodeParameterTest(md5: "768665e4bad0372b7cdcc8be6040621e", factory: { Delay(input) })
        nodeParameterTest(md5: "871872be5b831bd9f4f88f90ce2cd177", factory: { DiodeClipper(input) }, m1MD5: "f8fcb22a49489da6fb2d7d12cab10ce8")
        nodeParameterTest(md5: "2b0db813cce8ff7f2180d7a820737000", factory: { Distortion(input) })
        nodeParameterTest(md5: "3fe8139c1ce37fc14dfba77138345510", factory: { DynaRageCompressor(input) })
        nodeParameterTest(md5: "6173d108ae0fcede9e7f1f0b122622a9", factory: { Flanger(input) })
        //nodeParameterTest(md5: "dc2fcab5eeb367e93b3767a7f84f7491", factory: { PeakLimiter(input) })
        nodeParameterTest(md5: "d68057bc230214c09607509652dd8994", factory: { RhinoGuitarProcessor(input) })
        nodeParameterTest(md5: "547cc8833929d40042a0a00566cc032f", factory: { RingModulator(input) })
        nodeParameterTest(md5: "addc1655615279c0e02ae9f9db7b79b8", factory: { StereoDelay(input) })
        nodeParameterTest(md5: "2965f1e7d77deddb213a1ad56060e6e3", factory: { StereoFieldLimiter(input) })

    }

    func nodeParameterTest2(md5: String, factory: (Node)->Node, m1MD5: String = "", audition: Bool = false) {

        let bundle = Bundle.module
        let url = bundle.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let node = factory(player)

        let duration = node.parameters.count + 1

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer? = nil

        engine.output = node

        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            player.play()
            player.isLooping = true
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }

        for i in 0 ..< node.parameters.count {

            let node = factory(player)
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
        XCTAssertTrue([md5, m1MD5].contains(bigBuffer!.md5), "\(node) produced \(bigBuffer!.md5)")
    }

    func test2() {
        
        #if os(iOS)
        nodeParameterTest2(md5: "28d2cb7a5c1e369ca66efa8931d31d4d", factory: { player in Reverb(player) })
        #endif
        
        #if os(macOS)
        nodeParameterTest2(md5: "bff0b5fa57e589f5192b17194d9a43cb", factory: { player in Reverb(player) })
        #endif
        
    }
    
    func testFilters() {
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        nodeParameterTest(md5: "4120a8fefb4efe8f455bc8c001ab1538", factory: { HighPassFilter(input) })
        nodeParameterTest(md5: "5aaeb38a15503c162334f0ec1bfacfcd", factory: { HighShelfFilter(input) })
        nodeParameterTest(md5: "aeec895e45341249b7fc23ea688dfba8", factory: { LowPassFilter(input) })
        nodeParameterTest(md5: "2f81a7a8c9325863b4afa312ca066ed8", factory: { LowShelfFilter(input) })
    }
}
