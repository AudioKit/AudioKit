//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## 3D Panner
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

let panner = AK3DPanner(player)

AudioKit.output = panner
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("3D Panner")

        addButtons()

        addSubview(AKPropertySlider(
            property: "X",
            value: panner.x, minimum: -10, maximum: 10,
            color: AKColor.redColor()
        ) { sliderValue in
            panner.x = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Y",
            value: panner.y, minimum: -10, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            panner.y = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Z",
            value: panner.z, minimum: -10, maximum: 10,
            color: AKColor.cyanColor()
        ) { sliderValue in
            panner.z = sliderValue
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

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
