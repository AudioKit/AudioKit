//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Clip
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "drumloop.wav", fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var clipper = AKClipper(player)

//: Set the initial limit of the clipper here
clipper.limit = 0.1

AudioKit.output = clipper
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    var limitLabel: Label?

    override func setup() {
        addTitle("Clipper")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        limitLabel = addLabel("Limit: \(clipper.limit)")
        addSlider(#selector(setLimit), value: clipper.limit)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav", fromBaseDirectory: .resources)
        try? player.replaceFile(file!)
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

    func setLimit(slider: Slider) {
        clipper.limit = Double(slider.value)
        let limit = String(format: "%0.1f", clipper.limit)
        limitLabel!.text = "Limit: \(limit)"
    }


    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    limit = \(String(format: "%0.3f", clipper.limit))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [
