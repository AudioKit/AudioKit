// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKOperationGeneratorParametersTests: AKTestCase {

    let gen = AKOperationGenerator { parameters in
        AKOperation.sineWave(frequency: parameters[0], amplitude: parameters[1])
    }

    override func setUp() {
        afterStart = { self.gen.start() }
        duration = 1.0
    }

    func testSetParameters() {
        gen.parameter1 = 333
        gen.parameter2 = 0.5
        engine.output = gen
        AKTest()
    }

}

class AKOperationEffectParametersTests: AKTestCase {
    func testSetParameters() {
        let effect = AKOperationEffect(input) { player, parameters in
            let time = AKOperation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = AKOperation.sineWave(frequency: parameters[2])
                .scale(minimum: 0.5, maximum: 0.9)
            return player.variableDelay(time: time,
                                        feedback: feedback,
                                        maximumDelayTime: 1.0)
        }
        effect.parameter1 = 0.02
        effect.parameter2 = 1
        effect.parameter3 = 0.99
        engine.output = effect
        AKTest()
    }

    func testSetParameters2() {
        let effect = AKOperationEffect(input) { player, parameters in
            let time = AKOperation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = AKOperation.sineWave(frequency: parameters[2])
                .scale(minimum: 0.5, maximum: 0.9)
            return player.variableDelay(time: time,
                                        feedback: feedback,
                                        maximumDelayTime: 1.0)
        }
        effect.parameter1 = 0.02
        effect.parameter2 = 2
        effect.parameter3 = 0.99
        engine.output = effect
        AKTest()
    }

    func testSetParameters3() {
        let effect = AKOperationEffect(input) { player, parameters in
            let time = AKOperation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = AKOperation.sineWave(frequency: parameters[2])
                .scale(minimum: 0.5, maximum: 0.9)
            return player.variableDelay(time: time,
                                        feedback: feedback,
                                        maximumDelayTime: 1.0)
        }
        effect.parameter1 = 0.02
        effect.parameter2 = 2
        effect.parameter3 = 0.5
        engine.output = effect
        AKTest()
    }
}
