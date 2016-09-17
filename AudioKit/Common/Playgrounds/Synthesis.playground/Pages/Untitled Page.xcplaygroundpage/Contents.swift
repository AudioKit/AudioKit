import AudioKit
import PlaygroundSupport


var freq = AKSuperDuperParameter(value: 600)
var amp = AKSuperDuperParameter(value: 1)

//freq.operation = AKOperation.sineWave(frequency: 1, amplitude: 1).scale(minimum: 500, maximum: 1000)
//amp.operation = AKOperation.sineWave(frequency: 1, amplitude: 1).scale(minimum: 0, maximum: 1)
freq.setOperation("1 1 sine 500 1000 biscale")
amp.setOperation("1 1 sine 0 0.1 biscale")

let oscillator = AKSuperOscillator() //waveform: AKTable(.Sine), frequency: 600)
oscillator.frequency = freq
oscillator.amplitude = amp

AudioKit.output = AKMixer(oscillator)

AudioKit.start()
oscillator.start()

class PlaygroundView: AKPlaygroundView {

    var keyboard: AKKeyboardView?

    override func setup() {
        addSubview(AKPropertySlider(
            property: "Value",
            value:  Double(oscillator.frequency.value), minimum: 100, maximum: 1200,
            color: AKColor.green
        ) { sliderValue in
            freq.value = sliderValue
            if sliderValue > 1000 {
                oscillator.frequency = 200
            } else if sliderValue < 400 {
                oscillator.frequency = freq
            }
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
