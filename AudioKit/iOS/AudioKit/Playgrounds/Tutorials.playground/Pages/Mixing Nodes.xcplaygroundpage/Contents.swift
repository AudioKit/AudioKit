//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: ### So, what about connecting multiple sources to the output instead of
//: ### feeding operations into each other in sequential order? To do that, you'll need a mixer.
import XCPlayground
import AudioKit

//: This section prepares the players
let drumFile = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)
let bassFile = try AKAudioFile(readFileName: "bassloop.wav", baseDir: .Resources)

let guitarFile = try AKAudioFile(readFileName: "guitarloop.wav", baseDir: .Resources)

let leadFile = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .Resources)

var drums  = try AKAudioPlayer(file: drumFile)
var bass   = try AKAudioPlayer(file: bassFile)
var guitar = try AKAudioPlayer(file: guitarFile)
var lead   = try AKAudioPlayer(file: leadFile)

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
        
        addButton("Start All", action: #selector(start))
        addButton("Stop All", action: #selector(stop))

        addSubview(AKPropertySlider(
            property: "Drums Volume",
            value: drums.volume,
            color: AKColor.greenColor()
        ) { sliderValue in
            drums.volume = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Drums Pan",
            value: drums.pan, minimum: -1, maximum: 1,
            color: AKColor.redColor()
        ) { sliderValue in
            drums.pan = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Bass Volume",
            value: bass.volume,
            color: AKColor.greenColor()
        ) { sliderValue in
            bass.volume = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Bass Pan",
            value: bass.pan, minimum: -1, maximum: 1,
            color: AKColor.redColor()
        ) { sliderValue in
            bass.pan = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Guitar Volume",
            value: guitar.volume,
            color: AKColor.greenColor()
        ) { sliderValue in
            guitar.volume = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Guitar Pan",
            value: guitar.pan, minimum: -1, maximum: 1,
            color: AKColor.redColor()
        ) { sliderValue in
            guitar.pan = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Lead Volume",
            value: lead.volume,
            color: AKColor.greenColor()
        ) { sliderValue in
            lead.volume = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Lead Pan",
            value: lead.pan, minimum: -1, maximum: 1,
            color: AKColor.redColor()
        ) { sliderValue in
            lead.pan = sliderValue
            })
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
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
