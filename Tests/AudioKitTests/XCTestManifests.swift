import XCTest

#if !canImport(ObjectiveC)
/// All tests
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AudioKitTests.allTests),
    ]
}
#endif
