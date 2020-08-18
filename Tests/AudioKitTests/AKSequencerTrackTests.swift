// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFoundation

class AKSequencerTrackTests: AKTestCase {

    let flute = AKFlute()

    func getTestSequence() -> AKSequence {

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func testEmptyTrack() {
        let seq = AKSequencerTrack(targetNode: flute)
        XCTAssertFalse(seq.isPlaying)

        XCTAssertEqual(seq.length, 4.0) // One measure
        XCTAssertEqual(seq.loopEnabled, true) // Loop on
    }

    func testLoop() {

        duration = 5

        let track = AKSequencerTrack(targetNode: flute)
        output = flute

        track.sequence = getTestSequence()
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        // auditionTest()
        AKTestMD5("dc0d2c869f272195494e1a3e08bb8bcf")
    }

    func testOneShot() {

        duration = 5

        let track = AKSequencerTrack(targetNode: flute)
        output = flute

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        //auditionTest()
        AKTestMD5("53d23f4b60e5e9d12631eb39df1e4d96")
    }

    func testTempo() {

        duration = 5

        let track = AKSequencerTrack(targetNode: flute)
        output = flute

        track.sequence = getTestSequence()
        track.tempo = 60
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        // auditionTest()
        AKTestMD5("e8f75a12a6c786a0e5f27cb3a6b078bf")

    }

}
