// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import CAudioKit
import XCTest

class ErrorHandlingTests: XCTestCase {
	func testExceptionCatcher() {
		do {
			try ExceptionCatcher {
				// engine is nil, so this will throw this error:
				// required condition is false: _engine != nil
				AudioPlayer().play()
			}
		} catch let error as NSError {
			// and it should be caught here:
			Log("👍", error)
			return
		}
		XCTFail("ExceptionCatcher didn't catch the error")
	}
}
