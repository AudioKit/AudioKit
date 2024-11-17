import XCTest
import AVFoundation

final class AVAudioFileTests: XCTestCase {

    func testReadFile() throws {

        let sampleURL = Bundle.module.url(forResource: "TestResources/0001_1-16", withExtension: "wav")!

        let wavFile = try AVAudioFile(forReading: sampleURL)

        let pcmBuffer = wavFile.toAVAudioPCMBuffer()!

        XCTAssertEqual(Int(wavFile.length), Int(pcmBuffer.frameLength))
    }

}
