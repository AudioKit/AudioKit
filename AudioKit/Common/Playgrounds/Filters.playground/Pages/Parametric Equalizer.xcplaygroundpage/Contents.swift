//: ## Parametric Equalizer
//: A parametric equalizer can be used to raise or lower specific frequencies
//: or frequency bands. Live sound engineers often use parametric equalizers
//: during a concert in order to keep feedback from occuring, as they allow
//: much more precise control over the frequency spectrum than other
//: types of equalizers. Acoustic engineers will also use them to tune a room.
//: This node may be useful if you're building an app to do audio analysis.
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var parametricEQ = AKParametricEQ(player)
parametricEQ.centerFrequency = 4000 // Hz
parametricEQ.q = 1.0 // Hz
parametricEQ.gain = 10 // dB

AudioKit.output = parametricEQ
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Parametric EQ")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: parametricEQ))

        addSubview(AKPropertySlider(
            property: "Center Frequency",
            format:  "%0.3f Hz",
            value: parametricEQ.centerFrequency,  maximum: 22050,
            color: AKColor.green
        ) { sliderValue in
            parametricEQ.centerFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Q",
            value: parametricEQ.q,  maximum: 20,
            color: AKColor.red
        ) { sliderValue in
            parametricEQ.q = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Gain",
            format:  "%0.1f dB",
            value: parametricEQ.gain,  minimum: -20, maximum: 20,
            color: AKColor.cyan
        ) { sliderValue in
            parametricEQ.gain = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
