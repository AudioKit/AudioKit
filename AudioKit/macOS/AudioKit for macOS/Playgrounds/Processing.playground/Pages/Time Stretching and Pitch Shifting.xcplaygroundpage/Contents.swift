//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a
//: ### player-generated sound.  It does not work on live input or generated signals.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var timePitch = AKTimePitch(player)

//: Set the parameters here
timePitch.rate = 2.0
timePitch.pitch = -400.0
timePitch.overlap = 8.0

AudioKit.output = timePitch
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Time/Pitch")

        addButtons()

        addLabel("Time/Pitch Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Rate",
            format: "%0.3f",
            value: timePitch.rate, minimum: 0.3125, maximum: 5,
            color: AKColor.greenColor()
        ) { sliderValue in
            timePitch.rate = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Pitch",
            format: "%0.3f Cents",
            value: timePitch.pitch, minimum: -2400, maximum: 2400,
            color: AKColor.redColor()
        ) { sliderValue in
            timePitch.pitch = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Overlap",
            value: timePitch.overlap, minimum: 3, maximum: 32,
            color: AKColor.cyanColor()
        ) { sliderValue in
            timePitch.overlap = sliderValue
            })
    }
    
    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
    }

    func process() {
        timePitch.start()
    }

    func bypass() {
        timePitch.bypass()
    }


}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
