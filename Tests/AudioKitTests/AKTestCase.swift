// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit
import Foundation

class AKTestCase: XCTestCase {

    var duration = 0.1
    var output: AKNode?

    var input = AKOscillator()

    var afterStart: () -> Void = {}

    func auditionTest() {
        if let existingOutput = output {
            try! AKManager.auditionTest(node: existingOutput, duration: duration, afterStart: afterStart)
        }
    }

    func AKTest(_ testName: String = "") {
        var localMD5 = ""
        if let existingOutput = output {
            localMD5 = try! AKManager.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        var name = testName
        if name == "" {
            name = self.description
        }
        XCTAssert(validatedMD5s[name] == localMD5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    func AKTestNoEffect() {
        AKTest("testNoEffect")
    }

    override func setUp() {
        super.setUp()
        afterStart = { self.input.start() }
        AKDebugDSPSetActive(true)
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        AKManager.disconnectAllInputs()
        try! AKManager.stop()
        super.tearDown()
        AKDebugDSPSetActive(false)
    }

}
