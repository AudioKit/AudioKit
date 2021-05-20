// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@testable import AudioKit
import XCTest

class GenericOperationTests: XCTestCase {
    func defaultTest(_ md5: String, _ operation: AudioKit.Operation, audition: Bool = false) {
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

    func testGenerators() {
        let ramp = Operation.lineSegment(trigger: Operation.periodicTrigger(period: 1), start: 0.0, end: 1.0, duration: 1.0)
        defaultTest("e82a86ae4e7d47f24eeba9700e4745d4", Operation.fmOscillator())
        defaultTest("d9f1c155c150b5be489377ac7d510367", Operation.fmOscillator(baseFrequency: 10_000 * ramp))
        defaultTest("df1279e80a00419a84ded35141c088e4", Operation.fmOscillator(carrierMultiplier: 1_000 * ramp))
        defaultTest("f4cc261bdf98ae17320f9561941c8664", Operation.morphingOscillator())
        defaultTest("3828cd394361df9739360d1b910516cf", Operation.phasor())
        defaultTest("79e0b102124e0b7521fb277d3f8d27f9", Operation.pinkNoise())
        defaultTest("6704180ca2db755fd17742bb5d2da047", Operation.pinkNoise(amplitude: 0.5))
        defaultTest("bdef4981144f808c1a375a277f4da66f", Operation.pluckedString(trigger: Operation.metronome()))
        defaultTest("379388bf41f4ece5cf274bf53f270c46", Operation.sawtooth())
        defaultTest("2a5f4c75768a09c068f2c27377142aa7", Operation.sawtoothWave())
        defaultTest("91ec96732b1d1d40a585b6415eef8b51", Operation.sineWave())
        defaultTest("9e7c2af4b9e70a73ca7d8453d59d6953", Operation.square())
        defaultTest("9d4465fdcff811f568807c43e41859e1", Operation.squareWave())
        defaultTest("fc235d00451be0893bb69d971ce2832f", Operation.triangle())
        defaultTest("c95b04e9e39e47f3f26a8b9c96c7fe0e", Operation.triangleWave())
        defaultTest("5b3296351674e4e4d3a5cca9a1bf355f", Operation.vocalTract())
        defaultTest("bbe4898f76a6bd42a573f618ba831372", Operation.whiteNoise())
        defaultTest("1bdd36a87d9d1a9df891eac4073b9eb3", Operation.whiteNoise(amplitude: 0.5))
    }
    
    func testEffects() {
        let input = Operation.triangle()
        defaultTest("0cf9c4cd7a70f48e31b323540f365709", input.bitCrush() )
        defaultTest("c4e04aa637c6509db9b8ae3c1c41f70e", input.bitCrush(bitDepth: 7) )
        defaultTest("5d28729547dbfb905eb890fe6ef3b5c6", input.bitCrush(sampleRate: 4_000) )
        defaultTest("3fdcc5e1cae820dd78ac5899ca1f8c8a", input.bitCrush(bitDepth: 7, sampleRate: 4_000) )
        defaultTest("e2996e3be4916978068370badfb7e0e6", input.clip() )
        defaultTest("58b11ef50752c62d6fba69c4b209326f", input.clip(0.5) )
        defaultTest("e91da38b298af51b5c2d11032b951135", input.dcBlock() )
        defaultTest("fa9cc80070670c9197077f7c99a941a9", input.distort())
        defaultTest("9eddbd3f55e0d1502117867c3f123b4f", input.highPassButterworthFilter())
        defaultTest("eb229d6421f9d10f7f67c1ee7552645e", input.highPassFilter())
        defaultTest("dfc9fe00e68ef3484dc8e1e0d579b802", input.highPassFilter(halfPowerPoint: 100))
        defaultTest("403984fd06d667882c00d1095fd5a049", input.korgLowPassFilter())
        defaultTest("8e1d867e88945e87c5bcdcacad40f1d0", input.korgLowPassFilter(cutoffFrequency: 2_000))
        defaultTest("31cd577bbbc779d6766ea06856506623", input.korgLowPassFilter(resonance: 0.9))
        defaultTest("354effe4cc4a76f0d719e95046d2c059", input.korgLowPassFilter(saturation: 0.5))
        defaultTest("172e0909b75f65a3177d39b35dd2fc1c", input.korgLowPassFilter(cutoffFrequency: 2_000, resonance: 0.9, saturation: 0.5))
        defaultTest("e98ecf679fb2719032547edbd4698922", input.lowPassButterworthFilter() )
        defaultTest("f8cf4d107fdf86d414d9443c1004f545", input.lowPassFilter())
        defaultTest("610d75428245fb0f61ab2a6c70e38a90", input.modalResonanceFilter())
        defaultTest("cd808ced1a67801fda02a115e16aea18", input.moogLadderFilter() )
        defaultTest("2492706f3ebaaf2ea56e2276bedab140", input.resonantFilter() )
        defaultTest("4fe7d3c8a545ef1977902c803bd8e780", input.reverberateWithChowning() )
        defaultTest("34a8432a564417a01f17ee2806fa62fa", input.reverberateWithCombFilter() )
        defaultTest("18d5019f893191ba5e51e6621b022383", input.reverberateWithFlatFrequencyResponse() )
        defaultTest("7c73ff68ff48d4e81d4443619a75e81d", input.stringResonator() )
        defaultTest("671a9fa25803283c9b7df893bf78c147", input.threePoleLowPassFilter() )
    }
}
