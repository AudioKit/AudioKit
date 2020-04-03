//
//  pluckedStringTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class PluckedStringTests: AKTestCase {

    let pluckedString = AKOperationGenerator { _ in
        return AKOperation.pluckedString(trigger: AKOperation.metronome())
    }
    
    override func setUp() {
        afterStart = { self.pluckedString.start() }
        duration = 1.0
    }

    func testDefault() {
        output = pluckedString
        AKTestMD5("382cdbd27558fed9c8723ba435cdb4cf")
    }

}
