//: ## Low Pass Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowPassFilter = AKLowPassFilter(player)
lowPassFilter.cutoffFrequency = 6_900 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: lowPassFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: lowPassFilter.cutoffFrequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            lowPassFilter.cutoffFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Resonance",
            format: "%0.1f dB",
            value: lowPassFilter.resonance, minimum: -20, maximum: 40,
            color: AKColor.red
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
