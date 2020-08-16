// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKTremoloTests: AKTestCase {

    func testDefault() {
        output = AKTremolo(input)
        AKTestMD5("77fc5be08f1a46f4106fc88e5573c632")
    }

    func testDepth() {
        output = AKTremolo(input, depth: 0.5)
        AKTestMD5("e487730846899208773c9cefe2047f58")
    }

    func testFrequency() {
        output = AKTremolo(input, frequency: 20)
        AKTestMD5("5d33fc3f7bd4f467c464fa51cb7edbd5")
    }

    func testParameters() {
        output = AKTremolo(input, frequency: 20, depth: 0.5)
        AKTestMD5("81593bd2f89aa1ee6def976244a4d149")
    }

}
