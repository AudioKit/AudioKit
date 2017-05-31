//: ## Metronome with Callback
//:
//: This is a pretty advanced example using Sporth and callback functions to have a metronome that also display a visual flash on every beat.
import AudioKitPlaygrounds
import AudioKit

let sporth = "480 2 (0 p) 60 / metro (_callback f) (1 p) 0 count dup 2 pset (1 p) / 0.49 + round - * 1 sine (0 p) 60 / metro 0.01 0 0.05 tenv * dup"
let timer = AKOperationGenerator(sporth: sporth, customUgens: [callbackUgen])

timer.parameters = [60, 4, -1]
class PlaygroundView: AKPlaygroundView {
    
    var timeSlider: AKPropertySlider!
    
    override func setup() {
        addTitle("Metronome with Callback")
        
        timeSlider = AKPropertySlider(
            property: "",
            value: 0,
            color: AKColor.yellow
        ) { _ in
            // Nothing
        }
        addSubview(timeSlider)
        
        addSubview(AKButton(title: "Stop", color: AKColor.red) {
            timer.stop()
            return ""
        })
        
        addSubview(AKButton(title: "Start") {
            timer.restart()
            timer.parameters[2] = -1
            return ""
        })
        
        addSubview(AKPropertySlider(
            property: "Sudivision",
            format: "%0.0f",
            value: 4, minimum: 1, maximum: 10,
            color: AKColor.red
        ) { sudivision in
            timer.parameters[1] = round(sudivision)
        })
        
        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240,
            color: AKColor.green
        ) { frequency in
            timer.parameters[0] = frequency
        })
    }
}

let view = PlaygroundView()

let callback: AKCallback = { _ in
    view.timeSlider.value = 1.0
    view.timeSlider.property = "Beat \(1 + Int((timer.parameters[2] + 1).truncatingRemainder(dividingBy: timer.parameters[1])))"

    DispatchQueue.main.async {
        view.timeSlider.needsDisplay = true
    }
    
    let deadlineTime = DispatchTime.now() + (60/timer.parameters[0])/10.0
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        view.timeSlider.value = 0.0
    }
}

callbackUgen.userData = callback
AudioKit.output = timer
AudioKit.start()
timer.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
