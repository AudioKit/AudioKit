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

    func testMD5(buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = self.description
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    func AKFinishSegmentedTest(_ testName: String? = nil) {
        engine.stop()

        let localMD5 = buffer.md5

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
