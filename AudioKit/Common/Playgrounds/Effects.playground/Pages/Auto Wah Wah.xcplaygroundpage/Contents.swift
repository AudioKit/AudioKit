//: ## Auto Wah Wah
//: One of the most iconic guitar effects is the wah-pedal.
//: This playground runs an audio loop of a guitar through an AKAutoWah node.
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var wah = AKAutoWah(player)
wah.wah = 1
wah.amplitude = 1

AudioKit.output = wah
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Auto Wah Wah")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Wah",
            value: wah.wah,
            color: AKColor.green
        ) { sliderValue in
            wah.wah = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
