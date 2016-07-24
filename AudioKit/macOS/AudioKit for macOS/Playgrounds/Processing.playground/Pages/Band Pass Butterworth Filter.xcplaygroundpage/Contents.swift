//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Band Pass Butterworth Filter
//: ### Band-pass filters allow audio above a specified frequency range and
//: ### bandwidth to pass through to an output. The center frequency is the starting point
//: ### from where the frequency limit is set. Adjusting the bandwidth sets how far out
//: ### above and below the center frequency the frequency band should be.
//: ### Anything above that band should pass through.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a band pass filter
var filter = AKBandPassButterworthFilter(player)

//: Set the parameters of the band pass filter here
filter.centerFrequency = 5000 // Hz
filter.bandwidth = 600  // Cents
filter.rampTime = 1.0
AudioKit.output = filter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var centerFrequencyLabel: Label?
    var bandwidthLabel: Label?

    override func setup() {
        addTitle("Band Pass Butterworth Filter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("Band Pass Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        centerFrequencyLabel = addLabel("Center Frequency: \(filter.centerFrequency) Hz")
        addSlider(#selector(setCenterFrequency),
                  value: filter.centerFrequency,
                  minimum: 20,
                  maximum: 22050)

        bandwidthLabel = addLabel("Bandwidth \(filter.bandwidth) Cents")
        addSlider(#selector(setBandwidth), value: filter.bandwidth, minimum: 100, maximum: 12000)
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
        filter.play()
    }

    func bypass() {
        filter.bypass()
    }

    func setCenterFrequency(slider: Slider) {
        filter.centerFrequency = Double(slider.value)
        let frequency = String(format: "%0.1f", filter.centerFrequency)
        centerFrequencyLabel!.text = "Center Frequency: \(frequency) Hz"
        printCode()
    }

    func setBandwidth(slider: Slider) {
        filter.bandwidth = Double(slider.value)
        let bandwidth = String(format: "%0.1f", filter.bandwidth)
        bandwidthLabel!.text = "Bandwidth: \(bandwidth) Cents"
        printCode()
    }


    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    centerFrequency = \(String(format: "%0.3f", filter.centerFrequency))")
        Swift.print("    bandwidth = \(String(format: "%0.3f", filter.bandwidth))")
        Swift.print("}\n")
    }
}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
