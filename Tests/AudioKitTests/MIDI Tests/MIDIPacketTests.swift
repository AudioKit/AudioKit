// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CoreMIDI

final class MIDIPacketTests: XCTestCase {

    func testExtractData() throws {

        var packet = MIDIPacket()
        packet.length = 0
        XCTAssertEqual(extractPacketData(&packet), [])
        var result = extractPacket(&packet)!
        XCTAssertEqual(result.length, 0)

        packet.length = 1
        packet.data.0 = 1
        XCTAssertEqual(extractPacketData(&packet), [1])

        result = extractPacket(&packet)!
        XCTAssertEqual(result.length, 1)
        XCTAssertEqual(result.data.0, 1)

        packet.length = 3
        packet.data.0 = 1
        packet.data.1 = 2
        packet.data.2 = 3
        XCTAssertEqual(extractPacketData(&packet), [1,2,3])

        result = extractPacket(&packet)!
        XCTAssertEqual(result.length, 3)
        XCTAssertEqual(result.data.0, 1)
        XCTAssertEqual(result.data.1, 2)
        XCTAssertEqual(result.data.2, 3)
    }


}
