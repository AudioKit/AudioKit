//
//  sineWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class sineWaveTests: AKTestCase {
    
    override func setUp() {
        super.setUp()
        duration = 1.0
    }
    
    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.sineWave()
        }
        AKTestMD5("52c9b3999984c76adfe427316b11f515")
    }

}
