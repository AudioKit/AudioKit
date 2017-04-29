//: ## Variable Delay
//: When you smoothly vary effect parameters, you get completely new kinds of effects.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKVariableDelay(player)
delay.rampTime = 0.2
AudioKit.output = delay

var time = 0.0
let timeStep = 0.1

let modulation = AKPeriodicFunction(every: timeStep) {

    // Vary the delay time between 0.0 and 0.2 in a sinusoid at 2 hz
    let delayModulationHz = 0.1
    let delayModulation = (1.0 - cos(2 * 3.14 * delayModulationHz * time)) * 0.1
    delay.time = delayModulation

    let feedbackModulationHz = 0.21
    let feedbackModulation = (1.0 - sin(2 * 3.14 * feedbackModulationHz * time)) * 0.5
    delay.feedback = feedbackModulation
    time += timeStep
}

AudioKit.start(withPeriodicFunctions: modulation)
player.play()
modulation.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
