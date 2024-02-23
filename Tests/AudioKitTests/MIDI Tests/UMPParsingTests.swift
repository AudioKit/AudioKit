// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import AudioKit
import XCTest

import CoreMIDI

extension TestSender {
    func send(_ messages: UMPSysex ...) {
        send(words: messages.flatMap(\.words))
    }
}

class UMPParsingTests: XCTestCase {

    let midi = MIDI()
    let sender = TestSender()
    let listener = TestListener()

    override func setUpWithError() throws {
        #if os(iOS)
        throw XCTSkip("virtual outputs cannot be used on simulator")
        #else
        if #available(iOS 14.0, OSX 11.0, *) {
            midi.addListener(listener)
            midi.openInput(uid: sender.uniqueID)
        } else {
            throw XCTSkip("test needs OSX 11.0")
        }
        #endif
    }

    func testNoteOff() {
        sender.send(words: [MIDI1UPNoteOff(3, 4, 5, 6)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.noteOff(channel: 4, number: 5, velocity: 6, portID: sender.uniqueID)])
    }

    func testNoteOn() {
        sender.send(words: [MIDI1UPNoteOn(3, 4, 5, 6)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.noteOn(channel: 4, number: 5, velocity: 6, portID: sender.uniqueID)])
    }

    func testPolyPressure() {
        sender.send(words: [MIDI1UPChannelVoiceMessage(3, 0xA, 4, 5, 6)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.polyPressure(channel: 4, number: 5, value: 6, portID: sender.uniqueID)])
    }

    func testControlChange() {
        sender.send(words: [MIDI1UPControlChange(3, 4, 5, 6)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.controlChange(channel: 4, number: 5, value: 6, portID: sender.uniqueID)])
    }

    func testProgramChange() {
        sender.send(words: [MIDI1UPChannelVoiceMessage(3, 0xC, 4, 5, 0)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.programChange(channel: 4,
                                                          number: 5,
                                                          portID: sender.uniqueID)])
    }

    func testChannelPressure() {
        sender.send(words: [MIDI1UPChannelVoiceMessage(3, 0xD, 4, 5, 0)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.channelPressure(channel: 4,
                                                            value: 5,
                                                            portID: sender.uniqueID)])
    }

    func testPitchBend() {
        sender.send(words: [MIDI1UPPitchBend(3, 4, 5, 6)])
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.pitchBend(channel: 4,
                                                      value: UInt16(5) + UInt16(6) << 7,
                                                      portID: sender.uniqueID)])
    }

    func testSysexComplet4Bytes() {
        sender.send(.sysexComplete(data: [1, 2, 3, 4]))
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.systemCommand(data: [240, 1, 2, 3, 4, 247],
                                                          portID: sender.uniqueID)])
    }

    func testSysexCompleteNoBytes() {
        midi.openInput(uid: sender.uniqueID)
        sender.send(.sysexComplete(data: []))
        wait(for: [listener.received], timeout: 1)
        // for some reason CoreMIDI is sending to UMP64 messages with no data
        // we check the last one of them
        XCTAssertEqual(listener.messages.last, .systemCommand(data: [240, 247],
                                                          portID: sender.uniqueID))
    }

    func testSysexStartEnd() throws {
        sender.send(.sysexStart(data: [1, 2, 3, 4, 5]), .sysexEnd(data: [6, 7, 8]))
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.systemCommand(data: [240, 1, 2, 3, 4, 5, 6, 7, 8, 247],
                                                          portID: sender.uniqueID)])
    }

    func testSysexStartContinueWithNoBytesEnd() throws {
        sender.send(.sysexStart(data: [1, 2, 3, 4, 5]),
                    .sysexContinue(data: []),
                    .sysexEnd(data: [9, 10, 11]) )
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.systemCommand(data: [240, 1, 2, 3, 4, 5, 9, 10, 11, 247],
                                                          portID: sender.uniqueID)])
    }

    func testSysexStartContinueEnd() throws {
        sender.send(.sysexStart(data: [1, 2, 3, 4, 5]),
                    .sysexContinue(data: [6, 7, 8]),
                    .sysexEnd(data: [9, 10, 11]) )
        wait(for: [listener.received], timeout: 1)
        XCTAssertEqual(listener.messages, [.systemCommand(data: [240, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 247],
                                                          portID: sender.uniqueID)])
    }

    // Test for heap overflow encountered in https://github.com/AudioKit/AudioKit/issues/2890
    // will timeout if heap overflow is encountered
    func testHeapAllocation() {
        let overflowingMessage: [UInt8] = Array(repeating: 0x01, count: 260)
        midi.sendMessage(overflowingMessage)
    }

    func testSimultaneousStreams() throws {
        throw XCTSkip("skip test for now: sysex joining is not thread safe")

        //  this will fail for now because sysex joining is done via a single variable for all inputs

        /*
        let senderTwo = TestSender()
        midi.openInput(uid: senderTwo.uniqueID)

        sender.send(.sysexStart(data: [1, 2, 3, 4, 5]))
        senderTwo.send(.sysexStart(data: [11, 12, 13, 14, 15]))
        sender.send(.sysexEnd(data: [6, 7]))

        wait(for: [listener.received], timeout: 1)

        XCTAssertEqual(listener.messages,
                       [.systemCommand(data: [240, 1, 2, 3, 4, 5, 6, 7, 247], portID: sender.uniqueID)])
         */
    }
}
#endif
