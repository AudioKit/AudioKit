// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFoundation

class AKSequencerTrackTests: XCTestCase {

    func getTestSequence() -> AKSequence {
        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func testEmptyTrack() {
        let flute = AKFlute()
        let seq = AKSequencerTrack(targetNode: flute)
        XCTAssertFalse(seq.isPlaying)

        XCTAssertEqual(seq.length, 4.0) // One measure
        XCTAssertEqual(seq.loopEnabled, true) // Loop on
    }

    func testLoop() {
        let engine = AKEngine()
        let flute = AKFlute()

        let track = AKSequencerTrack(targetNode: flute)
        engine.output = flute

        track.sequence = getTestSequence()
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)

        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testOneShot() {

        let engine = AKEngine()
        let flute = AKFlute()

        let track = AKSequencerTrack(targetNode: flute)
        engine.output = flute

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        //auditionTest()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testTempo() {

        let engine = AKEngine()
        let flute = AKFlute()

        let track = AKSequencerTrack(targetNode: flute)
        engine.output = flute

        track.sequence = getTestSequence()
        track.tempo = 60
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)

    }

}
