//: ## Formant Filter
//: ##
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKFormantFilter(player)

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Formant Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Center Frequency",
            format: "%0.1f Hz",
            value: filter.centerFrequency, maximum: 8000,
            color: AKColor.yellow
        ) { sliderValue in
            filter.centerFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: filter.attackDuration, maximum: 0.1,
            color: AKColor.green
        ) { duration in
            filter.attackDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Decay",
            format: "%0.3f s",
            value: filter.decayDuration, maximum: 0.1,
            color: AKColor.cyan
        ) { duration in
            filter.decayDuration = duration
            })
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
