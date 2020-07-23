import AudioKit
import Combine

class OscillatorConductor: Conductor, ObservableObject {
    var osc = AKOscillator()
    @Published var isPlaying = false {
        didSet {
            isPlaying ? osc.play() : osc.stop()
        }
    }
    @Published var frequency: AUValue = 440 {
        didSet {
            osc.frequency = frequency
        }
    }

    override func setup() {
        osc.amplitude = 0.2
        AKManager.output = osc
        osc.stop()
        isPlaying = false
    }
}
