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
let drumFile   = bundle.pathForResource("drumloop", ofType: "wav")
let bassFile   = bundle.pathForResource("bassloop", ofType: "wav")
let guitarFile = bundle.pathForResource("guitarloop", ofType: "wav")
let leadFile   = bundle.pathForResource("leadloop", ofType: "wav")

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
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        addLabel("Drums Volume")
        addSlider(#selector(self.setDrumsVolume(_:)), value: drums.volume)

        addLabel("Drums Pan")
        addSlider(#selector(self.setDrumsPan(_:)), value: drums.pan, minimum: -1, maximum: 1)

        addLabel("Bass Volume")
        addSlider(#selector(self.setBassVolume(_:)), value: bass.volume)

        addLabel("Bass Pan")
        addSlider(#selector(self.setBassPan(_:)), value: bass.pan, minimum: -1, maximum: 1)

        addLabel("Guitar Volume")
        addSlider(#selector(self.setGuitarVolume(_:)), value: guitar.volume)

        addLabel("Guitar Pan")
        addSlider(#selector(self.setGuitarPan(_:)), value: guitar.pan, minimum: -1, maximum: 1)

        addLabel("Lead Volume")
        addSlider(#selector(self.setLeadVolume(_:)), value: lead.volume)

        addLabel("Lead Pan")
        addSlider(#selector(self.setLeadPan(_:)), value: lead.pan, minimum: -1, maximum: 1)
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

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
