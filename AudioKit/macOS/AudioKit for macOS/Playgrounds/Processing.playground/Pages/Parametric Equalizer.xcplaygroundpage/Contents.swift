//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parametric Equalizer
//: #### A parametric equalizer can be used to raise or lower specific frequencies
//: ### or frequency bands. Live sound engineers often use parametric equalizers
//: ### during a concert in order to keep feedback from occuring, as they allow
//: ### much more precise control over the frequency spectrum than other
//: ### types of equalizers. Acoustic engineers will also use them to tune a room.
//: ### This node may be useful if you're building an app to do audio analysis.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var parametricEQ = AKParametricEQ(player)

//: Set the parameters here
parametricEQ.centerFrequency = 4000 // Hz
parametricEQ.q = 1.0 // Hz
parametricEQ.gain = 10 // dB

AudioKit.output = parametricEQ
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var centerFreqLabel: Label?
    var qLabel: Label?
    var gainLabel: Label?

    override func setup() {
        addTitle("Parametric EQ")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("Parametric EQ Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        centerFreqLabel = addLabel("Center Frequency: \(parametricEQ.centerFrequency) Hz")
        addSlider(#selector(setCenterFreq),
                  value: parametricEQ.centerFrequency,
                  minimum: 20,
                  maximum: 22050)

        qLabel = addLabel("Q: \(parametricEQ.q) Hz")
        addSlider(#selector(setQ), value: parametricEQ.q, minimum: 0.1, maximum: 20)

        gainLabel = addLabel("Gain: \(parametricEQ.gain) dB")
        addSlider(#selector(setGain), value: parametricEQ.gain, minimum: -20, maximum: 20)

    }

    //: Handle UI Events

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(part)loop.wav", baseDir: .Resources)
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

    func process() {
        parametricEQ.start()
    }

    func bypass() {
        parametricEQ.bypass()
    }

    func setCenterFreq(slider: Slider) {
        parametricEQ.centerFrequency = Double(slider.value)
        let centerFrequency = String(format: "%0.1f", parametricEQ.centerFrequency)
        centerFreqLabel!.text = "Center Frequency: \(centerFrequency) Hz"
        printCode()
    }

    func setQ(slider: Slider) {
        parametricEQ.q = Double(slider.value)
        let q = String(format: "%0.1f", parametricEQ.q)
        qLabel!.text = "Q: \(q) Hz"
        printCode()
    }

    func setGain(slider: Slider) {
        parametricEQ.gain = Double(slider.value)
        let gain = String(format: "%0.1f", parametricEQ.gain)
        gainLabel!.text = "gain: \(gain) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    centerFrequency = " +
            String(format: "%0.3f", parametricEQ.centerFrequency))
        Swift.print("    q = \(String(format: "%0.3f", parametricEQ.q))")
        Swift.print("    gain = \(String(format: "%0.3f", parametricEQ.gain))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
