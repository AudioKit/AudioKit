//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: ### So, what about connecting multiple sources to the output instead of feeding operations into each other in sequential order? To do that, you'll need a mixer.
import XCPlayground
import AudioKit

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let drumFile   = bundle.pathForResource("drumloop.wav", ofType: "wav")
let bassFile   = bundle.pathForResource("bassloop.wav.wav", ofType: "wav")
let guitarFile = bundle.pathForResource("guitarloop.wav", ofType: "wav")
let leadFile   = bundle.pathForResource("leadloop.wav", ofType: "wav")

var drums  = AKAudioPlayer(drumFile!)
var bass   = AKAudioPlayer(bassFile!)
var guitar = AKAudioPlayer(guitarFile!)
var lead   = AKAudioPlayer(leadFile!)

drums.looping  = true
bass.looping   = true
guitar.looping = true
lead.looping   = true

//: Any number of inputs can be summed into one output
let mixer = AKMixer(drums, bass, guitar, lead)

AudioKit.output = mixer
AudioKit.start()

drums.play()
bass.play()
guitar.play()
lead.play()

//: Adjust the individual track volumes here
drums.volume  = 0.9
bass.volume   = 0.9
guitar.volume = 0.6
lead.volume   = 0.7

drums.pan  = 0.0
bass.pan   = 0.0
guitar.pan = 0.2
lead.pan   = -0.2

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Mixer")
        
        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Drums Volume")
        addSlider(#selector(setDrumsVolume), value: drums.volume)
        
        addLabel("Drums Pan")
        addSlider(#selector(setDrumsPan), value: drums.pan, minimum: -1, maximum: 1)
        
        addLabel("Bass Volume")
        addSlider(#selector(setBassVolume), value: bass.volume)
        
        addLabel("Bass Pan")
        addSlider(#selector(setBassPan), value: bass.pan, minimum: -1, maximum: 1)
        
        addLabel("Guitar Volume")
        addSlider(#selector(setGuitarVolume), value: guitar.volume)
        
        addLabel("Guitar Pan")
        addSlider(#selector(setGuitarPan), value: guitar.pan, minimum: -1, maximum: 1)
        
        addLabel("Lead Volume")
        addSlider(#selector(setLeadVolume), value: lead.volume)
        
        addLabel("Lead Pan")
        addSlider(#selector(setLeadPan), value: lead.pan, minimum: -1, maximum: 1)
    }
    
    func start() {
        drums.play()
        bass.play()
        guitar.play()
        lead.play()
    }
    func stop() {
        drums.stop()
        bass.stop()
        guitar.stop()
        lead.stop()
    }

    func setDrumsVolume(slider: Slider) {
        drums.volume = Double(slider.value)
    }
    
    func setDrumsPan(slider: Slider) {
        drums.pan = Double(slider.value)
    }
    
    func setBassVolume(slider: Slider) {
        bass.volume = Double(slider.value)
    }
    
    func setBassPan(slider: Slider) {
        bass.pan = Double(slider.value)
    }
    
    func setGuitarVolume(slider: Slider) {
        guitar.volume = Double(slider.value)
    }
    
    func setGuitarPan(slider: Slider) {
        guitar.pan = Double(slider.value)
    }
    
    func setLeadVolume(slider: Slider) {
        lead.volume = Double(slider.value)
    }
    
    func setLeadPan(slider: Slider) {
        lead.pan = Double(slider.value)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previou