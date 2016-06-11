//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tone and Tone Complement Filters
//: ##
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var toneFilter = AKToneFilter(player)
var toneComplement = AKToneComplementFilter(toneFilter)

AudioKit.output = toneComplement
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {
    
    var label1: Label?
    var label2: Label?
    
    override func setup() {
        addTitle("Tone Filters")
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop",  action: #selector(stop))
        
        addLabel("Tone Filter: ")
        addButton("Process", action: #selector(processTone))
        addButton("Bypass",  action: #selector(bypassTone))

        label1 = addLabel("Tone Filter 1/2 Power Point: \(toneFilter.halfPowerPoint)")
        addSlider(#selector(setToneFilterHalfPowerPoint),
                  value: toneFilter.halfPowerPoint,
                  minimum: 1,
                  maximum: 10000)

        addLabel("Tone Complement Filter: ")
        addButton("Process", action: #selector(processToneComplement))
        addButton("Bypass", action: #selector(bypassToneComplement))

        label2 = addLabel("Tone Complement 1/2 Power Point: \(toneComplement.halfPowerPoint)")
        addSlider(#selector(setToneComplementHalfPowerPoint),
                  value: toneComplement.halfPowerPoint,
                  minimum: 1,
                  maximum: 10000)
    }
    
    func start() {
        player.play()
    }
    func stop() {
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
    
    func setToneFilterHalfPowerPoint(slider: Slider) {
        toneFilter.halfPowerPoint = Double(slider.value)
        let hp = String(format: "%0.1f", toneFilter.halfPowerPoint)
        label1!.text = "Tone Filter 1/2 Power Point: \(hp)"
    }
    
    func setToneComplementHalfPowerPoint(slider: Slider) {
        toneComplement.halfPowerPoint = Double(slider.value)
        let hp = String(format: "%0.1f", toneComplement.halfPowerPoint)
        label2!.text = "Tone Complement 1/2 Power Point: \(hp)"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
