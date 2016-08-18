//: ## Band Pass Butterworth Filter
//: ### Band-pass filters allow audio above a specified frequency range and
//: ### bandwidth to pass through to an output. The center frequency is the starting point
//: ### from where the frequency limit is set. Adjusting the bandwidth sets how far out
//: ### above and below the center frequency the frequency band should be.
//: ### Anything above that band should pass through.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a band pass filter
var filter = AKBandPassButterworthFilter(player)
filter.centerFrequency = 5000 // Hz
filter.bandwidth = 600 // Cents
filter.rampTime = 1.0
AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Band Pass Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Center Frequency",
            format: "%0.1f Hz",
            value: filter.centerFrequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.centerFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Bandwidth",
            format: "%0.1f Hz",
            value: filter.bandwidth, minimum: 100, maximum: 1200,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.bandwidth = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
