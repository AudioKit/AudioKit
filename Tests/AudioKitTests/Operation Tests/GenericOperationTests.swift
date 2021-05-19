// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@testable import AudioKit
import XCTest

class GenericOperationTests: XCTestCase {
    func defaultTest(md5: String, operation: AudioKit.Operation, audition: Bool = false) {
        let engine = AudioEngine()
        let generator = OperationGenerator { operation }
        engine.output = generator
        generator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        XCTAssertEqual(audio.md5, md5, "\(operation) produced \(audio.md5)")
        
        if audition { audio.audition() }
    }

    func testDefaultGenerators() {
        defaultTest(md5: "e82a86ae4e7d47f24eeba9700e4745d4", operation: Operation.fmOscillator())
        defaultTest(md5: "f4cc261bdf98ae17320f9561941c8664", operation: Operation.morphingOscillator())
        defaultTest(md5: "3828cd394361df9739360d1b910516cf", operation: Operation.phasor())
        defaultTest(md5: "379388bf41f4ece5cf274bf53f270c46", operation: Operation.sawtooth())
        defaultTest(md5: "2a5f4c75768a09c068f2c27377142aa7", operation: Operation.sawtoothWave())
        defaultTest(md5: "91ec96732b1d1d40a585b6415eef8b51", operation: Operation.sineWave())
        defaultTest(md5: "9e7c2af4b9e70a73ca7d8453d59d6953", operation: Operation.square())
        defaultTest(md5: "9d4465fdcff811f568807c43e41859e1", operation: Operation.squareWave())
        defaultTest(md5: "fc235d00451be0893bb69d971ce2832f", operation: Operation.triangle())
        defaultTest(md5: "c95b04e9e39e47f3f26a8b9c96c7fe0e", operation: Operation.triangleWave())
        defaultTest(md5: "5b3296351674e4e4d3a5cca9a1bf355f", operation: Operation.vocalTract())
        defaultTest(md5: "bbe4898f76a6bd42a573f618ba831372", operation: Operation.whiteNoise())
    }
    
    func testDefaultEffects() {
        let input = Operation.triangle()
        defaultTest(md5: "0cf9c4cd7a70f48e31b323540f365709", operation: input.bitCrush() )
        defaultTest(md5: "e2996e3be4916978068370badfb7e0e6", operation: input.clip() )
        //defaultTest(md5: "fc235d00451be0893bb69d971ce2832f", operation: input.dcBlock())
        //defaultTest(md5: "fc235d00451be0893bb69d971ce2832f", operation: input.delay())
        defaultTest(md5: "9eddbd3f55e0d1502117867c3f123b4f", operation: input.highPassButterworthFilter())
        defaultTest(md5: "eb229d6421f9d10f7f67c1ee7552645e", operation: input.highPassFilter())
        defaultTest(md5: "e98ecf679fb2719032547edbd4698922", operation: input.lowPassButterworthFilter() )
        defaultTest(md5: "f8cf4d107fdf86d414d9443c1004f545", operation: input.lowPassFilter())
        defaultTest(md5: "cd808ced1a67801fda02a115e16aea18", operation: input.moogLadderFilter() )
        defaultTest(md5: "18d5019f893191ba5e51e6621b022383", operation: input.reverberateWithFlatFrequencyResponse() )
    }


}
