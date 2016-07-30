//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb
//: ### This is a great sounding reverb that we just love.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var reverb = AKCostelloReverb(player)

//: Set the parameters of the reverb here
reverb.cutoffFrequency = 9900 // Hz
reverb.feedback = 0.92

AudioKit.output = reverb
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencySlider: AKPropertySlider?
    var feedbackSlider: AKPropertySlider?

    override func setup() {
        addTitle("Sean Costello Reverb")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))
        addButton("Short Tail", action: #selector(presetShortTail))
        addButton("Low Ringing Tail", action: #selector(presetLowRingingTail))

        cutoffFrequencySlider = AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: reverb.cutoffFrequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            reverb.cutoffFrequency = sliderValue
            }
        addSubview(cutoffFrequencySlider!)


        feedbackSlider = AKPropertySlider(
            property: "Feedback",
            value: reverb.feedback,
            color: AKColor.redColor()
        ) { sliderValue in
            reverb.feedback = sliderValue
            }
        addSubview(feedbackSlider!)
    }



    func presetShortTail() {
        reverb.presetShortTailCostelloReverb()
        updateUI()
    }

    func presetLowRingingTail() {
        reverb.presetLowRingingLongTailCostelloReverb()
        updateUI()
    }

    func updateUI() {
        cutoffFrequencySlider?.value = reverb.cutoffFrequency
        feedbackSlider?.value = reverb.feedback
    }

    func printCode() {

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    cutoffFrequency = \(String(format: "%0.3f", reverb.cutoffFrequency))")
        Swift.print("    feedback = \(String(format: "%0.3f", reverb.feedback))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
