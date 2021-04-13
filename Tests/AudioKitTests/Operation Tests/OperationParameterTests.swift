// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class OperationGeneratorParametersTests: XCTestCase {

    func testSetParameters() {
        let engine = AudioEngine()
        let gen = OperationGenerator { parameters in
            Operation.sineWave(frequency: parameters[0], amplitude: parameters[1])
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
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let effect = OperationEffect(input) { player, parameters in
            let time = Operation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = Operation.sineWave(frequency: parameters[2])
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
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let effect = OperationEffect(input) { player, parameters in
            let time = Operation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = Operation.sineWave(frequency: parameters[2])
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
