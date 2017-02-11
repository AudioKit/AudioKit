//: ## Korg Low Pass Filter
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

var lowPassFilter = AKKorgLowPassFilter(player)

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Korg Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: lowPassFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: lowPassFilter.cutoffFrequency, minimum: 20, maximum: 5_000,
            color: AKColor.green
        ) { sliderValue in
            lowPassFilter.cutoffFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Resonance",
            format: "%0.3f",
            value: lowPassFilter.resonance, minimum: 0, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Saturation",
            format: "%0.3f",
            value: lowPassFilter.resonance, minimum: 0, maximum: 2,
            color: AKColor.cyan
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
