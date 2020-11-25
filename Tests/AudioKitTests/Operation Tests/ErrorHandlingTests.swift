// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class ErrorHandlingTests: XCTestCase {
    func testExceptionCatcher() {
        do {
            try ExceptionCatcher {
                // engine is nil, so this will throw this error:
                // required condition is false: _engine != nil
                // The AudioPlayer.play() wrapper method won't throw an error
                // as it checks for the engine state play the node directly
                AudioPlayer().playerNode.play()
            }
        } catch let error as NSError {
            // and it should be caught here:
            Log("👍", error)
            return
        }
        XCTFail("ExceptionCatcher didn't catch the error")
    }
}
