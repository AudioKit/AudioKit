//: ## Modal Resonance Filter
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKModalResonanceFilter(player)
filter.frequency = 300 // Hz
filter.qualityFactor = 20

let balancedOutput = AKBalancer(filter, comparator: player)
AudioKit.output = balancedOutput
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Modal Resonance Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.1f Hz",
            value: filter.frequency, maximum: 5000,
            color: AKColor.green
        ) { sliderValue in
            filter.frequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Quality Factor",
            format: "%0.1f",
            value: filter.qualityFactor, minimum: 0.1, maximum: 20,
            color: AKColor.red
        ) { sliderValue in
            filter.qualityFactor = sliderValue
            })

    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
