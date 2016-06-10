//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulator
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var ringModulator = AKRingModulator(player)

//: Set the parameters here
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

AudioKit.output = ringModulator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var ringModFreq1Label: Label?
    var ringModFreq2Label: Label?
    var ringModBalanceLabel: Label?
    var finalMixLabel: Label?
    
    override func setup() {
        addTitle("Ring Modulator")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Ring Modulator Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        ringModFreq1Label = addLabel("Frequency 1: \(ringModulator.frequency1) Hertz")
        addSlider(#selector(setFreq1), value: ringModulator.frequency1, minimum: 0.5, maximum: 8000)
        
        ringModFreq2Label = addLabel("Frequency 2: \(ringModulator.frequency2) Hertz")
        addSlider(#selector(setFreq2), value: ringModulator.frequency2, minimum: 0.5, maximum: 8000)
        
        ringModBalanceLabel = addLabel("Balance: \(ringModulator.balance)")
        addSlider(#selector(setBalance), value: ringModulator.balance)
        
        finalMixLabel = addLabel("Finalmix: \(ringModulator.mix)")
        addSlider(#selector(setMix), value: ringModulator.mix)
        
    }
    
    //: Handle UI Events
    
    func startLoop(part: String) {
        player.stop()
        let file = bundle.pathForResource("\(part)loop", ofType: "wav")
        player.replaceFile(file!)
        player.play()
    }
    
    func startDrumLoop() {
        startLoop("drum")
    }
    
    func startBassLoop() {
        startLoop("bass")
    }
    
    func startGuitarLoop() {
        startLoop("guitar")
    }
    
    func startLeadLoop() {
        startLoop("lead")
    }
    
    func startMixLoop() {
        startLoop("mix")
    }
    
    func stop() {
        player.stop()
    }
    
    func process() {
        ringModulator.start()
    }
    
    func bypass() {
        ringModulator.bypass()
    }
    func setFreq1(slider: Slider) {
        ringModulator.frequency1 = Double(slider.value)
        let ringModFreq1 = String(format: "%0.1f", ringModulator.frequency1)
        ringModFreq1Label!.text = "Frequency 1: \(ringModFreq1) Hertz"
    }
    
    func setFreq2(slider: Slider) {
        ringModulator.frequency2 = Double(slider.value)
        let ringModFreq2 = String(format: "%0.1f", ringModulator.frequency2)
        ringModFreq2Label!.text = "Frequency 2: \(ringModFreq2) Hertz"
    }
    
    func setBalance(slider: Slider) {
        ringModulator.balance = Double(slider.value)
        let ringModBalance = String(format: "%0.1f", ringModulator.balance)
        ringModBalanceLabel!.text = "Balance: \(ringModBalance)"
    }
    
    func setMix(slider: Slider) {
        ringModulator.mix = Double(slider.value)
        let finalMix = String(format: "%0.1f", ringModulator.mix)
        finalMixLabel!.text = "Mix: \(finalMix)"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
