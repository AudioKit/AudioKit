//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulator
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var ringModulator = AKRingModulator(player)
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

AudioKit.output = ringModulator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Ring Modulator")

        addButtons()
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Frequency 1",
            format: "%0.2f Hz",
            value: ringModulator.frequency1, minimum: 0.5, maximum: 8000,
            color: AKColor.greenColor()
            ) { sliderValue in
                ringModulator.frequency1 = sliderValue
        })
        
        addSubview(AKPropertySlider(
            property: "Frequency 2",
            format: "%0.2f Hz",
            value: ringModulator.frequency2, minimum: 0.5, maximum: 8000,
            color: AKColor.greenColor()
        ) { sliderValue in
            ringModulator.frequency2 = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Balance",
            value: ringModulator.balance,
            color: AKColor.redColor()
        ) { sliderValue in
            ringModulator.balance = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Mix",
            value: ringModulator.mix,
            color: AKColor.cyanColor()
        ) { sliderValue in
            ringModulator.mix = sliderValue
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

    func process() {
        ringModulator.start()
    }

    func bypass() {
        ringModulator.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
