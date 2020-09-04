// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKOperationGeneratorParametersTests: XCTestCase {

    func testSetParameters() {
        let engine = AKEngine()
        let gen = AKOperationGenerator { parameters in
            AKOperation.sineWave(frequency: parameters[0], amplitude: parameters[1])
        }
        gen.parameter1 = 333
        gen.parameter2 = 0.5
        engine.output = gen
        gen.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSetParameters2() {
        let engine = AKEngine()
        let input = AKOscillator()
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
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSetParameters3() {
        let engine = AKEngine()
        let input = AKOscillator()
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
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
