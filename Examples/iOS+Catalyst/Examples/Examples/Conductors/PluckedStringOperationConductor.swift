import AudioKit
import Combine

class PluckedStringOperationConductor: Conductor, ObservableObject {

    @Published var isPlaying = false {
        didSet {
            isPlaying ? performance?.start() : performance?.stop()
        }
    }

    var playRate = 2.0

    override func setup() {

        let pluckNode = AKOperationGenerator { parameters in
            let frequency = (AKOperation.parameters[1] + 40).midiNoteToFrequency()
            return AKOperation.pluckedString(
                trigger: AKOperation.trigger,
                frequency: frequency,
                amplitude: 0.5,
                lowestFrequency: 50)
        }

        let delay = AKDelay(pluckNode)
        delay.time = 1.5 / playRate
        delay.dryWetMix = 0.3
        delay.feedback = 0.2

        let reverb = AKReverb(delay)

        let scale = [0, 2, 4, 5, 7, 9, 11, 12]

        performance = AKPeriodicFunction(frequency: playRate) {
            var note = scale.randomElement()!
            let octave = [0, 1, 2, 3].randomElement()! * 12
            if random(in: 0...10) < 1.0 { note += 1 }
            if !scale.contains(note % 12) { AKLog("ACCIDENT!") }

            pluckNode.start()
            if random(in: 0...6) > 1.0 {
                pluckNode.parameters[1] = Double(note + octave)
                pluckNode.trigger()
            }
        }

        AKManager.output = reverb

        pluckNode.start()
        isPlaying = false
    }
}




