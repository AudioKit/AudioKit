import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {
    
    func testBasic() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        
        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file
        
        player.play()
        audio.append(engine.render(duration: 5.0))
        
        testMD5(audio)
    }
    
    func testLoop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let buffer = try? AVAudioPCMBuffer(url: url) else {
            XCTFail("Couldn't create buffer")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        player.buffer = buffer
        
        let audio = engine.startTest(totalDuration: 10.0)
        player.play()
        
        audio.append(engine.render(duration: 10.0))
        
        testMD5(audio)
    }
    
    func testPlayAfterPause() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        
        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file
        
        player.play()
        audio.append(engine.render(duration: 2.0))
        player.pause()
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))
        
        testMD5(audio)
    }
    
    func testEngineRestart() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        
        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file
        
        player.play()
        audio.append(engine.render(duration: 2.0))
        player.stop()
        engine.stop()
        _ = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))
        
        testMD5(audio)
    }
    
    func testScheduleFile() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.isLooping = true
        
        let audio = engine.startTest(totalDuration: 5.0)
        
        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.play()
        audio.append(engine.render(duration: 5.0))
        engine.stop()
        
        testMD5(audio)
    }
    
    func testVolume() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.file = file
        
        let audio = engine.startTest(totalDuration: 5.0)
        player.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
        
    }
    
    func testSeek() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        
        let audio = engine.startTest(totalDuration: 4.0)
        
        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 1.0)
        player.play()
        audio.append(engine.render(duration: 4.0))
        testMD5(audio)
    }
    
    func testGetCurrentTime() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 0.5)
        player.play()
        
        audio.append(engine.render(duration: 2.0))
        
        let currentTime = player.getCurrentTime()
        XCTAssertEqual(currentTime, 2.5)
        
        testMD5(audio)
    }
}
