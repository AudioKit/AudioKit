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

        output = AKMixer(track, synth)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)

        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("a76e58a693062a48c91e8abbf7965460")
    }

    func testRemoveNote() throws {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)
        seq.removeNote(at: 0.1)

        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("01209b83a22f436e0578dc9bcedecb62")
    }

    func testRemoveInstances() throws {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)
        seq.removeAllInstancesOf(noteNumber: 63)
        track.sequence = seq
        track.playFromStart()
        // auditionTest()
        AKTestMD5("648d39f6c4cb49d91d32245574319342")
    }

    func testTempo() {

        duration = 1

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)

        track.sequence = seq
        track.tempo = 30
        track.playFromStart()
        // auditionTest()
        AKTestMD5("96b39a3d1f94085eeebfd97c6c6c1253")

    }

    func getTestSequence() -> AKSequence {

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func testLoop() {

        duration = 5

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        track.sequence = getTestSequence()
        track.playFromStart()
        // auditionTest()
        AKTestMD5("c01d447a0f869a73f9ef82a9f2fa4607")
    }

    func testOneShot() {

        duration = 5

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()
        // auditionTest()
        AKTestMD5("3553248d0221171d23aab45b4772c7b0")
    }

}
