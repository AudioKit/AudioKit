// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKOperationParametersTests: AKTestCase {

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
        effect.parameters = [0.02, 1, 0.99]
        output = effect
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
        effect.parameters = [0.02, 2, 0.99]
        output = effect
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
        effect.parameters = [0.02, 2, 0.5]
        output = effect
        AKTest()
    }
}
