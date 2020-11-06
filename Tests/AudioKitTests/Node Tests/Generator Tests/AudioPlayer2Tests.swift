import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class AudioPlayer2Tests: XCTestCase {
    // C4 - C5
    let chromaticScale: [AUValue] = [261.63, 277.18, 293.66, 311.13, 329.63,
                                     349.23, 369.99, 392, 415.3, 440,
                                     466.16, 493.88] // , 523.25

    func generateTestFile(ofDuration duration: TimeInterval, frequencies: [AUValue]? = nil) -> URL? {
        let frequencies = frequencies ?? chromaticScale

        guard frequencies.count > 0 else { return nil }

        let pitchDuration = AUValue(duration) / AUValue(frequencies.count)

        Log("duration", duration, "pitchDuration", pitchDuration)

        let osc = Oscillator(waveform: Table(.square))
        let engine = AudioEngine()
        engine.output = osc

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("_io_audiokit_AudioPlayerRealtimeTests_temp.aiff")
        try? FileManager.default.removeItem(at: url)

        guard let file = try? AVAudioFile(forWriting: url,
                                          settings: Settings.defaultAudioFormat.settings) else {
            return nil
        }

        var startTime: AUValue = 0
        var notes = [AutomationEvent]()
        for pitch in frequencies {
            notes.append(AutomationEvent(targetValue: pitch, startTime: startTime, rampDuration: 0))
            startTime += pitchDuration
        }

        let zero = [AutomationEvent(targetValue: 0, startTime: 0, rampDuration: 0)]
        let fadeIn = [AutomationEvent(targetValue: 1, startTime: 0, rampDuration: pitchDuration)]
        let fadeOut = [AutomationEvent(targetValue: 0, startTime: AUValue(duration) - pitchDuration, rampDuration: pitchDuration)]

        Log(notes.map { $0.startTime })

        try? engine.avEngine.render(to: file, duration: duration, prerender: {
            osc.start()
            osc.$amplitude.automate(events: zero + fadeIn + fadeOut)
            osc.$frequency.automate(events: notes)
        })
        print("rendered test file to \(url)")

        return url
    }

    func testPause() {
        let frequencies = chromaticScale

        guard let url = generateTestFile(ofDuration: 12,
                                         frequencies: frequencies),
            let file = try? AVAudioFile(forReading: url) else {
            Log("Failed to open file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        try? engine.start()

        player.scheduleFile(url: url, at: nil) {
            Log("🏁 Completion Handler")
        }
        player.volume = 0.2

        var duration = file.duration

        Log("▶️")
        player.play()
        wait(for: 2)
        duration -= 2

        Log("⏸")
        player.pause()
        wait(for: 1)
        duration -= 1

        Log("▶️")
        player.play()

        wait(for: duration)
        Log("⏹")
    }

    func testScheduleFile() {
        guard let url = generateTestFile(ofDuration: 2,
                                         frequencies: chromaticScale),
            let file = try? AVAudioFile(forReading: url) else {
            Log("Failed to open file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        try? engine.start()

        // let audio = engine.startTest(totalDuration: 2.0)
        player.scheduleFile(file, at: AVAudioTime.now().offset(seconds: 4)) {
            Log("COMPLETE...")
        }

        player.play()

        wait(for: player.duration + 4)
    }

    func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }
}
