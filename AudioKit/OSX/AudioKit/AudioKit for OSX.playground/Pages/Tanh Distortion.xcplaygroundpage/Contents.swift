//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tanh Distortion
//: ##
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
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
    
    //: UI Elements we'll need to be able to access
    var pregainLabel: Label?
    var postgainLabel: Label?
    var postiveShapeParameterLabel: Label?
    var negativeShapeParameterLabel: Label?
    
    override func setup() {
        addTitle("Tanh Distortion")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Distortion Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        pregainLabel = addLabel("Pregain: \(distortion.pregain) Hz")
        addSlider(#selector(setPregain), value: distortion.pregain, minimum: 0, maximum: 10)

        postgainLabel = addLabel("Postgain: \(distortion.postgain) Hz")
        addSlider(#selector(setPostgain), value: distortion.postgain, minimum: 0, maximum: 10)

        postiveShapeParameterLabel = addLabel("Postive Shape Parameter: \(distortion.postiveShapeParameter)")
        addSlider(#selector(setPositiveShapeParameter), value: distortion.postiveShapeParameter, minimum: -10, maximum: 10)

        negativeShapeParameterLabel = addLabel("Negative Shape Parameter: \(distortion.negativeShapeParameter)")
        addSlider(#selector(setNegativeShapeParameter), value: distortion.negativeShapeParameter, minimum: -10, maximum: 10)

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
        distortion.start()
    }
    
    func bypass() {
        distortion.bypass()
    }
    
    func setPregain(slider: Slider) {
        distortion.pregain = Double(slider.value)
        let pregain = String(format: "%0.2f", distortion.pregain)
        pregainLabel!.text = "Pregain: \(pregain) Hz"
    }

    func setPostgain(slider: Slider) {
        distortion.postgain = Double(slider.value)
        let postgain = String(format: "%0.2f", distortion.postgain)
        postgainLabel!.text = "Postgain: \(postgain) Hz"
    }

    func setPositiveShapeParameter(slider: Slider) {
        distortion.postiveShapeParameter = Double(slider.value)
        let postiveShapeParameter = String(format: "%0.2f", distort