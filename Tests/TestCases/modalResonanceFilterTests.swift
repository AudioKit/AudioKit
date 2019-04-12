//
//  modalResonanceFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class ModalResonanceFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.modalResonanceFilter()
        }
        AKTestMD5("cdb0a984578ebb01f292eef9c295b5c9")
    }

}
