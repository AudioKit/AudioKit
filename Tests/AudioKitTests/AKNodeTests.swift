// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import XCTest
import AVFoundation
import CAudioKit

class AKNodeTests: AKTestCase {

    let osc = AKOscillator()

    func testNodeBasic() {
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()
        output = osc
        AKTest()
    }

    func testNodeConnection() {
        osc.start()
        let verb = AKCostelloReverb(osc)
        output = verb
        AKTest()
    }

    func testNodeDeferredConnection() {
        osc.start()
        let verb = AKCostelloReverb()
        osc >>> verb
        output = verb
        AKTest()
    }

    func testBadConnection() {

        let osc1 = AKOscillator()
        let osc2 = AKOscillator()

        osc1 >>> osc2

        XCTAssertEqual(osc2.connections.count, 0)
    }

    func testRedundantConnection() {

        let osc = AKOscillator()
        let mixer = AKMixer()
        osc >>> mixer
        osc >>> mixer
        XCTAssertEqual(mixer.connections.count, 1)
    }
}

class AKNodeDynamicConnectionTests: XCTestCase {

    func testDynamicConnection() {

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        let engine = AKEngine()
        let framesToRender = 2 * 44100
        engine.output = mixer

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

        engine.avEngine.reset()
        try! engine.avEngine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 44100)
        try! engine.start()

        osc.start()
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 88200)!
        do {
            try engine.avEngine.renderOffline(44100, to: buffer)
        } catch let err {
            print("1", err)
            return
        }

        let osc2 = AKOscillator(frequency: 881)
        osc2.start()

        osc2 >>> mixer
        do {
            try engine.avEngine.renderOffline(44100, to: buffer)
        } catch let err {
            print("2", err)
            return
        }

        engine.stop()

        let md5state = UnsafeMutablePointer<md5_state_s>.allocate(capacity: 1)
        md5_init(md5state)
        var samplesHashed = 0

        if let floatChannelData = buffer.floatChannelData {

            for frame in 0 ..< framesToRender {
                for channel in 0 ..< buffer.format.channelCount where samplesHashed < framesToRender {
                    let sample = floatChannelData[Int(channel)][Int(frame)]
                    withUnsafeBytes(of: sample) { samplePtr in
                        if let baseAddress = samplePtr.bindMemory(to: md5_byte_t.self).baseAddress {
                            md5_append(md5state, baseAddress, 4)
                        }
                    }
                    samplesHashed += 1
                }
            }

        }

        var digest = [md5_byte_t](repeating: 0, count: 16)
        var digestHex = ""

        digest.withUnsafeMutableBufferPointer { digestPtr in
            md5_finish(md5state, digestPtr.baseAddress)
        }

        for index in 0..<16 {
            digestHex += String(format: "%02x", digest[index])
        }

        md5state.deallocate()

        print(digestHex)


    }

    func testDynamicConnection2() {

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        let verb = AKCostelloReverb(osc2)
        osc2.start()

        verb >>> mixer

        sleep(1)

        engine.stop()
    }

    func testTwoEngines() {

        let engine1 = AKEngine()
        let engine2 = AKEngine()

        let osc = AKOscillator()
        engine1.output = osc
        osc.start()

        let verb = AKCostelloReverb(osc)
        engine2.output = verb

    }

    func testDisconnect() {

        let engine = AKEngine()
        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        osc.start()
        engine.output = mixer
        try! engine.start()

        sleep(1)

        mixer.disconnect(node: osc)

        print("disconnected")
        sleep(1)
        print("done")

        engine.stop()

    }

    func testDynamicConnection3() {

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()

        osc2 >>> mixer

        sleep(1)

        mixer.disconnect(node: osc2)

        sleep(1)

        engine.stop()
    }


    func testNodeDetach() {

        let engine = AKEngine()

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer
        osc.start()
        try! engine.start()
        sleep(1)

        osc.detach()
        sleep(1)

        engine.stop()

    }

    func testDynamicOutput() {

        let engine = AKEngine()

        let osc1 = AKOscillator()
        osc1.start()
        engine.output = osc1

        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        engine.output = osc2

        sleep(1)

        engine.stop()

    }


}
