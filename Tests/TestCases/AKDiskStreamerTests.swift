//
//  AKDiskStreamerTests.swift
//  iOSTestSuite
//
//  Created by Jeff Cooper on 6/28/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDiskStreamerTests: AKTestCase {

    var streamer: AKDiskStreamer?

    func testDoNothing() {
        setupStreamer()
        AKTestMD5("d2b120199019b639d5a7e2b3463e9c97")
    }

    func testPlayback() {
        setupStreamer()
        afterStart = {
            self.loadFile()
            self.streamer?.play()
        }
        AKTestMD5("5d836377d0098d7c1e3624a94e86e03d")
    }

    let testCompletionHandlerMD5 = "5f306e81c0e36951a048aae9874e9b40"

    func testCompletionHandler() {
        streamer?.completionHandler = {
            self.streamer?.play()
        }
        afterStart = {
            self.loadFile()
            self.streamer?.play()
        }
        AKTestMD5(testCompletionHandlerMD5)
    }

    func testForwardLoop() {
        afterStart = {
            self.loadFile()
            self.streamer?.loopEnabled = true
            self.streamer?.play()
        }
        AKTestMD5(testCompletionHandlerMD5)
    }

    func testSlowdown() {
        afterStart = {
            self.loadFile()
            self.streamer?.rate = 0.5
            self.streamer?.play()
        }
        AKTestMD5("c1f8dcf69cd781fdc94dc9866660fd79")
    }

    func testSpeedup() {
        afterStart = {
            self.loadFile()
            self.streamer?.rate = 1.5
            self.streamer?.play()
        }
        AKTestMD5("4615ccfa3a8fc8872197d604d835f57e")
    }

    func testSeek() {
        afterStart = {
            self.loadFile()
            self.streamer?.play()
            self.streamer?.seek(to: 1_000)
        }
        AKTestMD5("e448e20b096fa6e341ba6a419b1b4760")
    }

    func setupStreamer() {
        streamer = AKDiskStreamer()
        output = streamer
    }
    func loadFile() {
        if let path = Bundle.main.path(forResource: "sinechirp", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            let file = try! AKAudioFile(forReading: url)
            streamer?.load(file: file)
        } else {
            XCTFail("Could not load sinechirp.wav")
        }
    }

    override func setUp() {
        super.setUp()
        setupStreamer()
        duration = 1.0 // needs to be this long since the default time is one second
    }

}
