//: ## Node FFT Plot
//: An FFT plot displays a signal as relative amplitudes across the frequency spectrum.
//: This playground uses the microphone input to perform the FFT on and displays the plot in the playground's timeline view.
import AudioKitPlaygrounds
import AudioKit

var microphone = AKMicrophone()

//: Zero out the microphone to prevent feedback
AudioKit.output = AKBooster(microphone, gain: 0.0)
AudioKit.start()

public class PlaygroundView: AKPlaygroundView {
    public override func setup() {
        addTitle("Node FFT Plot")

        let plot = AKNodeFFTPlot(microphone, frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        plot.shouldFill = true
        plot.shouldMirror = false
        plot.shouldCenterYAxis = false
        plot.color = AKColor.purple
        plot.gain = 100
        addSubview(plot)
    }
}

import PlaygroundSupport
PlaygroundPage.current.liveView = PlaygroundView()
PlaygroundPage.current.needsIndefiniteExecution = true
