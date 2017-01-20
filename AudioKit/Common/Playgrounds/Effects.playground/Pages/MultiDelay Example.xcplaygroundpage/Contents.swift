//: ## MultiDelay Example
//: This is similar to the MultiDelay implemented in the Analog Synth X example project.
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

func multitapDelay(_ input: AKNode, times: [Double], gains: [Double]) -> AKMixer {
    let mix = AKMixer(input)
    zip(times, gains).forEach { (time, gain) -> () in
        let delay = AKVariableDelay(input, time: time)
        mix.connect(AKBooster(delay, gain: gain))
    }
    return mix
}

//: Delay Properties
var delayTime = 0.2 // Seconds
var delayMix  = 0.4 // 0 (dry) - 1 (wet)
let gains = [0.5, 0.25, 0.15].map { gain -> Double in gain * delayMix }
let input = player

//: Delay Definition
let leftDelay = multitapDelay(input,
    times: [1.5, 2.5, 3.5].map { t -> Double in t * delayTime },
    gains: gains)
let rightDelay = multitapDelay(input,
    times: [1, 2, 3].map { t -> Double in t * delayTime },
    gains: gains)
let delayPannedLeft = AKPanner(leftDelay, pan: -1)
let delayPannedRight = AKPanner(rightDelay, pan: 1)

let mix = AKMixer(delayPannedLeft, delayPannedRight)

AudioKit.output = mix
AudioKit.start()
player.play()


PlaygroundPage.current.needsIndefiniteExecution = true
