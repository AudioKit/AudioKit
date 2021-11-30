import Foundation
import AVFoundation
import AudioKit
import XCTest

class AVAudioPCMBufferTests: XCTestCase {
  func testAppend() {
    let path = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
    let file = try? AVAudioFile(forReading: path!)
    let loopBuffer = file!.toAVAudioPCMBuffer()!
    XCTAssertNoThrow(loopBuffer.append(file!.toAVAudioPCMBuffer()!))
  }
}
