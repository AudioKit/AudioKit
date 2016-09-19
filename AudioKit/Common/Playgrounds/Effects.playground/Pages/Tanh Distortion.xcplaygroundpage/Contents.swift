//: ## Tanh Distortion
//: ##
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var distortion = AKTanhDistortion(player)
distortion.pregain = 1.0
distortion.postgain = 1.0
distortion.postiveShapeParameter = 1.0
distortion.negativeShapeParameter = 1.0

AudioKit.output = distortion
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Tanh Distortion")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: distortion))

        addSubview(AKPropertySlider(
            property: "Pre-gain",
            value: distortion.pregain, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            distortion.pregain = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Post-gain",
            value: distortion.postgain, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            distortion.postgain = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Postive Shape Parameter",
            value: distortion.postiveShapeParameter, minimum: -10, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            distortion.postiveShapeParameter = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Negative Shape Parameter",
            value: distortion.negativeShapeParameter, minimum: -10, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            distortion.negativeShapeParameter = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
