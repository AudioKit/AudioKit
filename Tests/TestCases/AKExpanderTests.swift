// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKExpanderTests: AKTestCase {

    func testDefault() {
        output = AKExpander(input)
        AKTestMD5("025c0a9fdf87f47a13c1e8e97587e499")
    }
}
