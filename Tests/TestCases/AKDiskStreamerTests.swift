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
        AKTestMD5("d8bf32699a72873551a44e0a2758a5da")
    }

    let testCompletionHandlerMD5 = "e561e0d540fe09b09f7e3399d09829f5"

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
        AKTestMD5("71f031bac4f9c935c8a8ddf653b02f7c")
    }

    func testSpeedup() {
        afterStart = {
            self.loadFile()
            self.streamer?.rate = 1.5
            self.streamer?.play()
        }
        AKTestMD5("347e2708deb5684ebf97817e3b72f279")
    }

    func testSeek() {
        afterStart = {
            self.loadFile()
            self.streamer?.play()
            self.streamer?.seek(to: 1000)
        }
        AKTestMD5("c8da2c623a280eb9284bb41202d06d13")
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
