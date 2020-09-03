//: ## MultiDelay Example
//: This is similar to the MultiDelay implemented in the Analog Synth X example project.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var delays = [AKVariableDelay]()
var counter = 0

func multitapDelay(_ input: AKNode?, times: [Double], gains: [Double]) -> AKMixer {
    let mix = AKMixer(input)

    zip(times, gains).forEach { (time, gain) -> Void in
        delays.append(AKVariableDelay(input, time: time))
        mix.connect(AKBooster(delays[counter], gain: gain))
        counter += 1
    }
    return mix
}

//: Delay Properties
var delayTime = 0.2 // Seconds
var delayMix = 0.4 // 0 (dry) - 1 (wet)
let gains = [0.5, 0.25, 0.15].map { gain -> Double in gain * delayMix }
let input = player

//: Delay Definition
let leftDelay = multitapDelay(input,
                              times: [1.5, 2.5, 3.5].map { t -> Double in t * delayTime },
                              gains: gains)
let rightDelay = multitapDelay(input,
                               times: [1.0, 2.0, 3.0].map { t -> Double in t * delayTime },
                               gains: gains)
let delayPannedLeft = AKPanner(leftDelay, pan: -1)
let delayPannedRight = AKPanner(rightDelay, pan: 1)

let mix = AKMixer(delayPannedLeft, delayPannedRight)

engine.output = mix
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
