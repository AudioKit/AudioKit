// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFoundation

class AKSequencerTrackTests: AKTestCase {

    let sampler = AKAppleSampler()

    func getTestSequence() -> AKSequence {

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func setupSampler() {
        let bundle = Bundle(for: AKSequencerTrackTests.self)
        if let path = bundle.path(forResource: "sinechirp", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            let file = try! AVAudioFile(forReading: url)
            try! sampler.loadAudioFile(file)
            output = sampler
        } else {
            XCTFail("Could not load sinechirp.wav")
        }
    }


    func testEmptyTrack() {


        let seq = AKSequencerTrack(targetNode: sampler)
        XCTAssertFalse(seq.isPlaying)

        XCTAssertEqual(seq.length, 4.0) // One measure
        XCTAssertEqual(seq.loopEnabled, true) // Loop on
    }

    func testLoop() {

        duration = 5

        let track = AKSequencerTrack(targetNode: sampler)

        setupSampler()

        track.sequence = getTestSequence()
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        // auditionTest()
        AKTestMD5("8dda603e249554576192a2bd524f8bca")
    }

    func testOneShot() {

        duration = 5

        let track = AKSequencerTrack(targetNode: sampler)

        setupSampler()

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        //auditionTest()
        AKTestMD5("864f48d1881655b29fd1cca59887bed4")
    }

    func testTempo() {

        duration = 5

        let track = AKSequencerTrack(targetNode: sampler)

        setupSampler()

        track.sequence = getTestSequence()
        track.tempo = 60
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        //auditionTest()
        AKTestMD5("ca831ed474d2d302f48c37fd2cff4850")

    }

}
