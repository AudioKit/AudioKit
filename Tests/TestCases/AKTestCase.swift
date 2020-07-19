// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTestCase: XCTestCase {

    var duration = 0.1
    var output: AKNode?

    let sineOscillatorMD5 = "6ee413495f949542432eb00d32ecd903"

    var input = AKOscillator()

    var afterStart: () -> Void = {}

    func auditionTest() {
        if let existingOutput = output {
            try! AKManager.auditionTest(node: existingOutput, duration: duration, afterStart: afterStart)
        }
    }

    func AKTestMD5(_ md5: String, alternate: String = "") {
        var localMD5 = ""
        if let existingOutput = output {
            localMD5 = try! AKManager.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        XCTAssertTrue([md5, alternate].contains(localMD5) && localMD5 != sineOscillatorMD5 && localMD5 != "", localMD5)
    }

    func AKTestMD5Not(_ md5: String) {
        var localMD5 = ""
        if let existingOutput = output {
            localMD5 = try! AKManager.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        XCTAssertFalse(md5 == localMD5, localMD5)
    }

    func AKTestNoEffect() {
        var localMD5 = ""
        if let existingOutput = output {
            localMD5 = try! AKManager.test(node: existingOutput, duration: duration, afterStart: afterStart)
        }
        XCTAssertTrue(localMD5 == sineOscillatorMD5, localMD5)
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
