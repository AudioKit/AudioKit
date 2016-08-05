//
//  AKTestCase.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        AudioKit.stop()
        super.tearDown()
    }
    
}
