//
//  AKSamplePlayerTests.swift
//  AudioKitTestSuite
//
//  Created by Jeff Cooper and Aurelius Prochazka on 18 Dec 2017.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKSamplePlayerTests: AKTestCase {
    
    var sampler: AKSamplePlayer?
    
    func testDefault() {
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
    }
    
    func testReversePlayback(){
        sampler?.startPoint = sampler!.size
        sampler?.endPoint = 0
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("4ff8bf4506289ce8b4f5f26f6d3c77ac")
    }
    
    func testStartOffset(){
        afterStart = {
            self.sampler?.play(from: 2000)
        }
        AKTestMD5("d06ca74db9d9e5ca6892a5c6b32b978c")
    }
    
    func testStartOffsetUsingPoints(){
        sampler?.startPoint = 2000
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("d06ca74db9d9e5ca6892a5c6b32b978c")
    }
    
    func testEndOffset(){
        afterStart = {
            self.sampler?.play(from: 0, to: 300)
        }
        AKTestMD5("4fead31c7eb9c03698e8b94e286aa7ac")
    }
    
    func testEndOffsetUsingPoints(){
        sampler?.startPoint = 0
        sampler?.endPoint = 300
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("4fead31c7eb9c03698e8b94e286aa7ac")
    }
    
    func testForwardLoop(){
        sampler?.loopStartPoint = 100
        sampler?.loopEndPoint = 300
        sampler?.endPoint = 300
        sampler?.loopEnabled = true
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("664e78be6d2d3a3daef538f981e20ecd")
    }
    
    func testReverseLoop(){
        sampler?.loopStartPoint = 300
        sampler?.loopEndPoint = 100
        sampler?.endPoint = 300
        sampler?.loopEnabled = true
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("d8f001556a3efed4577101c2249b986c")
    }
    
    func setupSampler(){
        let path = Bundle.main.path(forResource: "sinechirp", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        let file = try! AKAudioFile(forReading: url)
        sampler = AKSamplePlayer(file: file)
        output = sampler
    }
    
    override func setUp() {
        super.setUp()
        setupSampler()
    }
    
}

