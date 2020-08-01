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

        let seq = AKSequencerTrack(targetNode: synth)

        output = AKMixer(synth, seq)

        seq.add(noteNumber: 60, position: 0, duration: 0.1)
        seq.add(noteNumber: 62, position: 0.1, duration: 0.1)
        seq.add(noteNumber: 63, position: 0.2, duration: 0.1)

        seq.playFromStart()
        // auditionTest()
        AKTestMD5("9bea8068185763c2b1a9970a916688fa")
    }

}
