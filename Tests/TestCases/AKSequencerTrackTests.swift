//
//  AKSequencerTrackTests.swift
//  macOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/31/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKSequencerTrackTests: AKTestCase {

    func testEmptyTrack() {

        let synth = AKOscillatorFilterSynth()
        let seq = AKSequencerTrack(targetNode: synth)

        XCTAssertEqual(seq.length, 4.0) // One measure
        XCTAssertEqual(seq.loopEnabled, true) // Loop on
    }

    func testBasicSequence() throws {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(synth, track)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)

        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("9bea8068185763c2b1a9970a916688fa")
    }

    func testRemoveNote() throws {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(synth, track)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)
        seq.removeNote(at: 0.1)

        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("ec7e33775d8c926b2676a7002c123360")
    }

    func testRemoveInstances() throws {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(synth, track)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)
        seq.removeAllInstancesOf(noteNumber: 63)
        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("a1c11d9faec613e1676d5db7e0a0f434")
    }

    func testTempo() {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(synth, track)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)

        track.sequence = seq
        track.tempo = 30
        track.playFromStart()
        // auditionTest()
        AKTestMD5("813ae62aad95c3ee3155cf212828410e")

    }

}
