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

    func testTempo() {

        duration = 5

        let synth = AKOscillatorFilterSynth()

        let track = AKSequencerTrack(targetNode: synth)

        output = AKMixer(track, synth)

        track.sequence = getTestSequence()
        track.tempo = 60
        track.playFromStart()
        // auditionTest()
        AKTestMD5("9e4ef9914e766652ebdb8eb9b952e458")

    }

}
