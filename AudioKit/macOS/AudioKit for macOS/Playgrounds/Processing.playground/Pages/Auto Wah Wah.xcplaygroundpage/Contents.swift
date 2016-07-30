//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Auto Wah Wah
//: ### One of the most iconic guitar effects is the wah-pedal.
//: ### This playground runs an audio loop of a guitar through an AKAutoWah node.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var wah = AKAutoWah(player)

//: Set the parameters of the auto-wah here
wah.wah = 1
wah.amplitude = 1

AudioKit.output = wah
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Auto Wah Wah")

        addButtons()

        addSubview(AKPropertySlider(
            property: "Wah",
            value: wah.wah,
            color: AKColor.greenColor()
        ) { sliderValue in
            wah.wah = sliderValue
            })
    }

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
    }

    func setWah(slider: Slider) {
        wah.wah = Double(slider.value)
        wahLabel!.text = "Wah: \(String(format: "%0.3f", wah.wah))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
