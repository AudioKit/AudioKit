import AudioKit
import AVFoundation
import XCTest

class AKPlayerTests: AKTestCase {

    // Because SPM doesn't support resources yet, render out a test file.
    func generateTestFile() -> URL {

        let osc = AKOscillator()
        let engine = AKEngine()
        engine.output = osc
        osc.start()

        // let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: true)!

        let mgr = FileManager.default
        let url = mgr.temporaryDirectory.appendingPathComponent("test.aiff")
        try? mgr.removeItem(at: url)
        let file = try! AVAudioFile(forWriting: url, settings: AKSettings.audioFormat.settings)

        try! engine.renderToFile(file, duration: 1)
        print("rendered test file to \(url)")

        return url
    }

    func testBasicOriginal() {
        let url = generateTestFile()

        let file = try! AVAudioFile(forReading: url)

        let engine = AKEngine()
        let player = AKPlayer()
        engine.output = player

        try! engine.start()
        player.scheduleFile(file, at: nil)
        player.play()
        sleep(5)
        engine.stop()

    }

    func testBasic() {
        let url = generateTestFile()

        let file = try! AVAudioFile(forReading: url)

        let engine = AKEngine()
        let player = AKPlayer()
        engine.output = player

        var audio = try! engine.startTest(totalDuration: 5.0)!
        player.scheduleFile(file, at: nil)
        player.play()
        audio.append(try! engine.render(duration: 5.0))
        testMD5(buffer: audio)
    }

    func testLoop() {
        let url = generateTestFile()
        let file = try! AVAudioFile(forReading: url)
        let buffer = try! AVAudioPCMBuffer(file: file)!

        let engine = AKEngine()
        let player = AKPlayer()
        engine.output = player

        duration = 5
        afterStart = {
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
        }
        AKTest()

    }

    func testScheduleEarly() {
        
        let url = generateTestFile()
        
        let file = try! AVAudioFile(forReading: url)
        
        let player = AKPlayer()
        player.scheduleFile(file, at: nil)
    }
    
}


