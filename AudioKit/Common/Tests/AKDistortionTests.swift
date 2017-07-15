//
//  AKDistortionTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDistortionTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDistortion(input)
        input.start()
        AKTestMD5("28422f7d452479da3f1902fbe9e14346")
    }
}
