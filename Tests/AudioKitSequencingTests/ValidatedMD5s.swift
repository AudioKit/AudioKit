import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = self.description
        XCTAssertFalse(buffer.isSilent)
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    "-[SequencerTrackTests testChangeTempo]": "3e05405bead660d36ebc9080920a6c1e",
    "-[SequencerTrackTests testLoop]": "3a7ebced69ddc6669932f4ee48dabe2b",
    "-[SequencerTrackTests testOneShot]": "3fbf53f1139a831b3e1a284140c8a53c",
    "-[SequencerTrackTests testTempo]": "1eb7efc6ea54eafbe616dfa8e1a3ef36",
]
