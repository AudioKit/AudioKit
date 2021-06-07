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
    "-[FaderTests testBypass]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testDefault]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testGain]": "a26597484ed5afc96d5db12d63b6a34b",
    "-[FaderTests testMany]": "6b2d34e86130813c7e7d9f1cf7a2a87c",
    "-[FaderTests testParameters]": "aae4e6e743cb9501e57b3761937d1e36",
    "-[FaderTests testParameters2]": "a26597484ed5afc96d5db12d63b6a34b",
    "-[SequencerTrackTests testChangeTempo]": "3e05405bead660d36ebc9080920a6c1e",
    "-[SequencerTrackTests testLoop]": "3a7ebced69ddc6669932f4ee48dabe2b",
    "-[SequencerTrackTests testOneShot]": "3fbf53f1139a831b3e1a284140c8a53c",
    "-[SequencerTrackTests testTempo]": "1eb7efc6ea54eafbe616dfa8e1a3ef36"
]
