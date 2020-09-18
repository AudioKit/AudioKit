//: ## Multi-tap Delay
//: A multi-tap delay is a delay line where multiple 'taps' or outputs are
//: taken from a delay buffer at different points, and the taps are then
//: summed with the original. Multi-tap delays are great for creating
//: rhythmic delay patterns, but they can also be used to create sound
//: fields of such density that they start to take on some of the qualities
//: we'd more usually associate with reverb. - Geoff Smith, Sound on Sound

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

//: In AudioKit, you can create a multitap easily through creating a function
//: that mixes together several delays and gains.
var delays = [VariableDelay]()

func multitapDelay(_ input: Node, times: [Double], gains: [Double]) -> Mixer {
    let mix = Mixer(input)
    var counter = 0
    zip(times, gains).forEach { (time, gain) -> Void in
        delays.append(VariableDelay(input, time: time))
        mix.connect(Fader(delays[counter], gain: gain))
        counter += 1
    }
    return mix
}

engine.output = multitapDelay(player, times: [0.1, 0.2, 0.4], gains: [0.5, 2.0, 0.5])
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
