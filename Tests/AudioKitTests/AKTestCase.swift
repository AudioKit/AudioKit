// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class AKTestCase: XCTestCase {

    var duration = 0.1

    let engine = AKEngine()
    var input = AKOscillator()

    var buffer: AVAudioPCMBuffer!

    var afterStart: () -> Void = {}

    func auditionTest() {
        try! engine.auditionTest(duration: duration, afterStart: afterStart)
    }

    func AKTest(_ testName: String? = nil) {
        let localMD5 = try! engine.test(duration: duration, afterStart: afterStart)
        let name = testName ?? self.description
        XCTAssert(validatedMD5s[name] == localMD5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    func AKFinishSegmentedTest(_ testName: String? = nil) {
        engine.stop()

        let md5state = UnsafeMutablePointer<md5_state_s>.allocate(capacity: 1)
        md5_init(md5state)
        var samplesHashed = 0

        let framesToRender = AVAudioFrameCount(duration * AKSettings.sampleRate)

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

        let localMD5 = digestHex

        let name = testName ?? self.description
        XCTAssert(validatedMD5s[name] == localMD5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    func AKStartSegmentedTest(duration firstDuration: Double) {
        let framesToRender = AVAudioFrameCount(duration * AKSettings.sampleRate)
        engine.avEngine.reset()
        try! engine.avEngine.enableManualRenderingMode(.offline, format: AKSettings.audioFormat, maximumFrameCount: framesToRender)
        try! engine.start()

        buffer = AVAudioPCMBuffer(pcmFormat: AKSettings.audioFormat, frameCapacity: framesToRender)!
        do {
            try engine.avEngine.renderOffline(AVAudioFrameCount(firstDuration * AKSettings.sampleRate), to: buffer)
        } catch let err {
            print(err)
        }
    }

    func AKAppendSegmentedTest(duration nextDuration: Double) {
        do {
            try engine.avEngine.renderOffline(AVAudioFrameCount(nextDuration * AKSettings.sampleRate), to: buffer)
        } catch let err {
            print(err)
        }
    }

    func AKTestNoEffect() {
        AKTest("testNoEffect")
    }

    override func setUp() {
        super.setUp()
        afterStart = { self.input.start() }
        AKDebugDSPSetActive(true)
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        engine.stop()
        super.tearDown()
        AKDebugDSPSetActive(false)
    }

}
