//: ## MultiDelay Example
//: This is similar to the MultiDelay implemented in the Analog Synth X example project.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var delays = [VariableDelay]()
var counter = 0

func multitapDelay(_ input: Node, times: [Double], gains: [Double]) -> Mixer {
    let mix = Mixer(input)

    zip(times, gains).forEach { (time, gain) -> Void in
        delays.append(VariableDelay(input, time: time))
        mix.connect(Fader(delays[counter], gain: gain))
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
let delayPannedLeft = Panner(leftDelay, pan: -1)
let delayPannedRight = Panner(rightDelay, pan: 1)

let mix = Mixer(delayPannedLeft, delayPannedRight)

engine.output = mix
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
