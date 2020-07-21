//
//  AKPlayerTests.swift
//  iOSTestSuiteTests
//
//  Created by Taylor Holliday on 7/21/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPlayerTests: AKTestCase {

    func testBasic() {

        guard let url = Bundle.main.url(forResource: "sinechirp", withExtension: "wav") else {
            XCTFail()
            return
        }

        guard let player = AKPlayer(url: url) else {
            XCTFail()
            return
        }

        afterStart = {
            player.play()
        }

        output = player

        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
    }

}
