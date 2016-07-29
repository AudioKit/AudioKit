//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
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

        addButtons()

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.1f Hz",
            value: filter.frequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.frequency = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Quality Factor",
            format: "%0.1f",
            value: filter.qualityFactor, minimum: 0.1, maximum: 20,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.qualityFactor = sliderValue
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

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
