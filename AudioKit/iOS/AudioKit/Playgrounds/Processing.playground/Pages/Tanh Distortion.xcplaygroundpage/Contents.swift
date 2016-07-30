//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tanh Distortion
//: ##
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var distortion = AKTanhDistortion(player)

//: Set the parameters here
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
            filenames: AKPlaygroundView.audioResourceFileNames))

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Pre-gain",
            value: distortion.pregain, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            distortion.pregain = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Post-gain",
            value: distortion.postgain, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            distortion.postgain = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Postive Shape Parameter",
            value: distortion.postiveShapeParameter, minimum: -10, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            distortion.postiveShapeParameter = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Negative Shape Parameter",
            value: distortion.negativeShapeParameter, minimum: -10, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            distortion.negativeShapeParameter = sliderValue
            })
    }


    func process() {
        distortion.start()
    }

    func bypass() {
        distortion.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
