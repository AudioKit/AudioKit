//: ## High Pass Butterworth Filter
//: A high-pass filter takes an audio signal as an input, and cuts out the
//: low-frequency components of the audio signal, allowing for the higher frequency
//: components to "pass through" the filter.
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var highPassFilter = AKHighPassButterworthFilter(player)
highPassFilter.cutoffFrequency = 6_900 // Hz

AudioKit.output = highPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("High Pass Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: highPassFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: highPassFilter.cutoffFrequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            highPassFilter.cutoffFrequency = sliderValue
            })

    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
