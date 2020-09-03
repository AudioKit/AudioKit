// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKShakerTests: AKTestCase {

    func testShaker() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .maraca)
        engine.output = shaker

        AKTest()
    }

    func testShakerType() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes)
        engine.output = shaker

        AKTest()
    }

    func testShakerAmplitude() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes, amplitude: 1.0)
        engine.output = shaker

        AKTest()
    }

}
