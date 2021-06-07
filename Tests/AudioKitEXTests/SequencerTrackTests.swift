// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import XCTest
import AudioKit
import AVFoundation
import AudioKitEX

class SequencerTrackTests: XCTestCase {

    func getTestSequence() -> NoteEventSequence {
        var seq = NoteEventSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 72, position: 1, duration: 0.5)
        seq.add(noteNumber: 84, position: 2, duration: 0.5)

        return seq
    }

    func testEmptyTrack() {
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try! AVAudioFile(forReading: sampleURL)
        try! sampler.loadAudioFile(audioFile)
        let seq = SequencerTrack(targetNode: sampler)
        let engine = AudioEngine()
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        XCTAssertFalse(seq.isPlaying)
        XCTAssertEqual(seq.length, 4.0) // One measure
        XCTAssertEqual(seq.loopEnabled, true) // Loop on
    }

    func testLoop() {
        let engine = AudioEngine()
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try! AVAudioFile(forReading: sampleURL)
        try! sampler.loadAudioFile(audioFile)

        let track = SequencerTrack(targetNode: sampler)
        engine.output = sampler

        track.sequence = getTestSequence()
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)

        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testOneShot() {

        let engine = AudioEngine()
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try! AVAudioFile(forReading: sampleURL)
        try! sampler.loadAudioFile(audioFile)

        let track = SequencerTrack(targetNode: sampler)
        engine.output = sampler

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testTempo() {

        let engine = AudioEngine()
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try! AVAudioFile(forReading: sampleURL)
        try! sampler.loadAudioFile(audioFile)

        let track = SequencerTrack(targetNode: sampler)
        engine.output = sampler

        track.sequence = getTestSequence()
        track.tempo = 60
        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testChangeTempo() {

        let engine = AudioEngine()
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try! AVAudioFile(forReading: sampleURL)
        try! sampler.loadAudioFile(audioFile)

        let track = SequencerTrack(targetNode: sampler)
        engine.output = sampler

        track.sequence = getTestSequence()

        track.playFromStart()
        XCTAssertTrue(track.isPlaying)
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 2.0))
        track.tempo = 60
        audio.append(engine.render(duration: 3.0))
        testMD5(audio)

    }

}
#endif
