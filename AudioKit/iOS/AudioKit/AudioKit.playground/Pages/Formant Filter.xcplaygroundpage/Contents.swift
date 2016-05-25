//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Formant Filter
//: ##
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var filter = AKFormantFilter(player)

AudioKit.output = filter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var centerFrequencyLabel: Label?
    var attackLabel: Label?
    var decayLabel: Label?
    
    override func setup() {
        addTitle("Formant Filter")
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Formant Filter Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        centerFrequencyLabel = addLabel("Center Frequency: \(filter.centerFrequency) Hz")
        addSlider(#selector(setCenterFrequency), value: filter.centerFrequency, minimum: 20, maximum: 22050)
        
        attackLabel = addLabel("Attack: \(filter.attackDuration) Seconds")
        addSlider(#selector(setAttack), value: filter.attackDuration, minimum: 0, maximum: 0.1)

        decayLabel = addLabel("Decay: \(filter.decayDuration) Seconds")
        addSlider(#selector(setDecay), value: filter.decayDuration, minimum: 0, maximum: 0.1)

    }
    
    //: Handle UI Events
    
    func start() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func process() {
        filter.play()
    }
    
    func bypass() {
        filter.bypass()
    }
    
    func setCenterFrequency(slider: Slider) {
        filter.centerFrequency = Double(slider.value)
        let frequency = String(format: "%0.1f", filter.centerFrequency)
        centerFrequencyLabel!.text = "Center Frequency: \(frequency) Hz"
    }
    
    func setAttack(slider: Slider) {
        filter.attackDuration = Double(slider.value)
        let attack = String(format: "%0.3f", filter.attackDuration)
        attackLabel!.text = "Attack: \(attack) Seconds"
    }

    func setDecay(slider: Slider) {
        filter.decayDuration = Double(slider.value)
        let decay = String(format: "%0.3f", filter.decayDuration)
        decayLabel!.text = "Decay: \(decay) Seconds"
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
