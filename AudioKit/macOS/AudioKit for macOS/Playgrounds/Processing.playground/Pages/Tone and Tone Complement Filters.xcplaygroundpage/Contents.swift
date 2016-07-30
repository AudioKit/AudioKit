//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tone and Tone Complement Filters
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var toneFilter = AKToneFilter(player)
var toneComplement = AKToneComplementFilter(toneFilter)

AudioKit.output = toneComplement
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Tone Filters")
        addButtons()

        addLabel("Tone Filter: ")
        addButton("Process", action: #selector(processTone))
        addButton("Bypass", action: #selector(bypassTone))

        addSubview(AKPropertySlider(
            property: "Half Power Point",
            value: toneFilter.halfPowerPoint, maximum: 10000,
            color: AKColor.greenColor()
        ) { sliderValue in
            toneFilter.halfPowerPoint = sliderValue
            })
        
        addLabel("Tone Complement Filter: ")
        addButton("Process", action: #selector(processToneComplement))
        addButton("Bypass", action: #selector(bypassToneComplement))
        
        addSubview(AKPropertySlider(
            property: "Half Power Point",
            value: toneComplement.halfPowerPoint, maximum: 10000,
            color: AKColor.greenColor()
        ) { sliderValue in
            toneComplement.halfPowerPoint = sliderValue
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

    func processTone() {
        toneFilter.start()
    }

    func bypassTone() {
        toneFilter.bypass()
    }

    func processToneComplement() {
        toneComplement.start()
    }

    func bypassToneComplement() {
        toneComplement.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
