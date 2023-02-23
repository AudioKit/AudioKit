// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CoreMIDI

final class MIDIPacketTests: XCTestCase {

    func testExtractData() throws {

        var packet = MIDIPacket()
        packet.length = 0
        XCTAssertEqual(extractPacketData(&packet), [])

        packet.length = 1
        packet.data.0 = 1
        XCTAssertEqual(extractPacketData(&packet), [1])

        packet.length = 3
        packet.data.0 = 1
        packet.data.1 = 2
        packet.data.2 = 3
        XCTAssertEqual(extractPacketData(&packet), [1,2,3])
    }


}
