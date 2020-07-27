import AudioKit
import SwiftUI

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

struct OscillatorView: View {
    @ObservedObject var conductor  = OscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
            }
            ParameterSlider(text: "Frequency", parameter: self.$conductor.frequency, range: 220...880)

        }.navigationBarTitle(Text("Oscillator"))
        .onAppear {
            self.conductor.start()
        }
    }
}

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView()
    }
}
