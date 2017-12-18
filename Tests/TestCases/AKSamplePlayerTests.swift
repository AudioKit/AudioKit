//
//  AKTanhDistortionTests.swift
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
        setupSampler()
        afterStart = {
            
        }
        AKTestMD5("882c7029a5097769b85bd176f5752684")
    }
    
    func setupSampler(){
        let path = Bundle.main.path(forResource: "sinechirp", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        let file = try! AKAudioFile(forReading: url)
        sampler = AKSamplePlayer(file: file)
        output = sampler
    }
    
}

