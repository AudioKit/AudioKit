// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import XCTest

extension URL {
    static var testAudio: URL {
        return Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
    }

    static var testAudioDrums: URL {
        return Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
    }
}

struct TestResult: Equatable {
    let md5: String
    let suiteName: String
    let testName: String
}

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        XCTAssertFalse(buffer.isSilent)

        let localMD5 = buffer.md5
        let pattern = "\\[(\\w+)\\s+(\\w+)\\]" // Regex for "-[testSuiteName testFunctionName]}
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: description, options: [], range: NSRange(description.startIndex..., in: description))

            if let match = matches.first {
                if let swiftRange1 = Range(match.range(at: 1), in: description),
                   let swiftRange2 = Range(match.range(at: 2), in: description) {
                    let suite = String(description[swiftRange1])
                    let name = String(description[swiftRange2])

                    let testResult = TestResult(md5: localMD5, suiteName: suite, testName: name)
                    XCTAssert(validTestResults.contains(testResult))
                    if !validTestResults.contains(testResult) {
                        let validTests = validTestResults.filter { $0.suiteName == suite && $0.testName == name }
                        if validTests.isEmpty {
                            print("No valid results found for this test, you may want to add it to validTestResults:")
                        } else {
                            print("None of the valid results (\(validTests.count) found) for this test match this result:")
                        }
                        print("TestResult(md5: \"\(localMD5)\", suiteName: \"\(suite)\", testName: \"\(name)\"),")
                    }
                }
            }
        } catch {
            print("Error creating regex: \(error)")
        }
    }
}



