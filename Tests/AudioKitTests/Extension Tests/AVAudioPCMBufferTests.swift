import Foundation
import AVFoundation
import AudioKit
import XCTest

class AVAudioPCMBufferTests: XCTestCase {
    func testAppend() {
        let path = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
        let file = try! AVAudioFile(forReading: path!)

        let fileBuffer = file.toAVAudioPCMBuffer()!
        let loopBuffer = AVAudioPCMBuffer(pcmFormat: fileBuffer.format, frameCapacity: 2 * UInt32(file.length))!

        loopBuffer.append(fileBuffer)
        XCTAssertNoThrow(loopBuffer.append(fileBuffer))
    }
}
