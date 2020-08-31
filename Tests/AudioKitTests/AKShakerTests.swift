// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKShakerTests: AKTestCase {

    func testShaker() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .maraca)
        output = shaker

        // auditionTest()
        AKTest()
    }

    func testShakerType() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes)
        output = shaker

        // auditionTest()
        AKTest()
    }

    func testShakerAmplitude() {

        akSetSeed(0)

        let shaker = AKShaker()
        shaker.trigger(type: .tunedBambooChimes, amplitude: 1.0)
        output = shaker

        // auditionTest()
        AKTest()
    }

}
