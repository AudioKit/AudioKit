//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Simple Reverb
//: ### This is an implementation of Apple's simplest reverb which only allows you to set presets

import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var reverb = AKReverb(player)

//: Load factory preset and give the dry/wet mix amount here
reverb.dryWetMix = 0.5

AudioKit.output = reverb
AudioKit.start()

player.play()
reverb.loadFactoryPreset(.Cathedral)

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Apple Reverb")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        addLineBreak()

        addLabel("Apple Reverb")

        addButton("Cathedral", action: #selector(loadCathedral))
        addButton("Large Chamber", action: #selector(loadLargeChamber))
        addButton("Large Hall", action: #selector(loadLargeHall))
        addButton("Large Hall 2", action: #selector(loadLargeHall2))
        addLineBreak()
        addButton("Large Room", action: #selector(loadLargeRoom))
        addButton("Large Room 2", action: #selector(loadLargeRoom2))
        addButton("Medium Chamber", action: #selector(loadMediumChamber))
        addLineBreak()
        addButton("Medium Hall", action: #selector(loadMediumHall))
        addButton("Medium Hall 2", action: #selector(loadMediumHall2))

        addButton("Medium Hall 3", action: #selector(loadMediumHall3))
        addLineBreak()
        addButton("Medium Room", action: #selector(loadMediumRoom))
        addButton("Plate", action: #selector(loadPlate))
        addButton("Small Room", action: #selector(loadSmallRoom))

        addLabel("Mix: ")
        addSlider(#selector(setDryWet), value: reverb.dryWetMix)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func loadCathedral() {
        reverb.loadFactoryPreset(.Cathedral)
    }

    func loadLargeChamber() {
        reverb.loadFactoryPreset(.LargeChamber)
    }

    func loadLargeHall() {
        reverb.loadFactoryPreset(.LargeHall)
    }

    func loadLargeHall2() {
        reverb.loadFactoryPreset(.LargeHall2)
    }

    func loadLargeRoom() {
        reverb.loadFactoryPreset(.LargeRoom)
    }

    func loadLargeRoom2() {
        reverb.loadFactoryPreset(.LargeRoom2)
    }

    func loadMediumChamber() {
        reverb.loadFactoryPreset(.MediumChamber)
    }

    func loadMediumHall() {
        reverb.loadFactoryPreset(.MediumHall)
    }

    func loadMediumHall2() {
        reverb.loadFactoryPreset(.MediumHall2)
    }

    func loadMediumHall3() {
        reverb.loadFactoryPreset(.MediumHall3)
    }

    func loadMediumRoom() {
        reverb.loadFactoryPreset(.MediumRoom)
    }

    func loadPlate() {
        reverb.loadFactoryPreset(.Plate)
    }

    func loadSmallRoom() {
        reverb.loadFactoryPreset(.SmallRoom)
    }




    func setDryWet(slider: Slider) {
        reverb.dryWetMix = Double(slider.value)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
