import AudioKit
import SwiftUI

class FMOscillatorConductor: Conductor, ObservableObject {
    var oscillator = AKFMOscillator()
    @Published var isPlaying = false {
        didSet {
            isPlaying ? oscillator.play() : oscillator.stop()
        }
    }
    @Published var baseFrequency: AUValue = 440 {
        didSet { oscillator.baseFrequency = baseFrequency }
    }
    @Published var carrierMultiplier: AUValue = 1 {
        didSet { oscillator.carrierMultiplier = carrierMultiplier }
    }
    @Published var modulatingMultiplier: AUValue = 1 {
        didSet { oscillator.modulatingMultiplier = modulatingMultiplier }
    }
    @Published var modulationIndex: AUValue = 1 {
        didSet { oscillator.modulationIndex = modulationIndex }
    }
    @Published var amplitude: AUValue = 1 {
        didSet { oscillator.amplitude = amplitude }
    }
    @Published var rampDuration: AUValue = 0.002 {
        didSet { oscillator.rampDuration = Double(rampDuration) }
    }

    func setValues() {
        baseFrequency = oscillator.baseFrequency
        carrierMultiplier = oscillator.carrierMultiplier
        modulatingMultiplier = oscillator.modulatingMultiplier
        modulationIndex = oscillator.modulationIndex
        amplitude = oscillator.amplitude
        rampDuration = AUValue(oscillator.rampDuration)
    }

    func randomize() {
        baseFrequency = random(in: 0...800)
        carrierMultiplier = random(in: 0...20)
        modulatingMultiplier = random(in: 0...20)
        modulationIndex = random(in: 0...100)
    }

    override func setup() {
        oscillator.amplitude = 0.1
        oscillator.rampDuration = 0.1
        AKManager.output = oscillator
        oscillator.stop()
        isPlaying = false
    }
}

struct PresetButton: View {
    var text: String
    var onTap: ()->Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray)
            Text(text).onTapGesture {
                self.onTap()
            }
        }
    }
}

struct FMOscillatorView: View {
    @ObservedObject var conductor = FMOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
            }
            HStack(spacing: 10) {
                PresetButton(text: "Stun Ray") { self.conductor.oscillator.presetStunRay(); self.conductor.setValues() }
                PresetButton(text: "Wobble")   { self.conductor.oscillator.presetWobble();  self.conductor.setValues() }
                PresetButton(text: "Fog Horn") { self.conductor.oscillator.presetFogHorn(); self.conductor.setValues() }
                PresetButton(text: "Buzzer")   { self.conductor.oscillator.presetBuzzer();  self.conductor.setValues() }
                PresetButton(text: "Spiral")   { self.conductor.oscillator.presetSpiral();  self.conductor.setValues() }
                PresetButton(text: "Random")   { self.conductor.randomize() }
                
            }.padding()
            ParameterSlider(text: "Base Frequency",
                            parameter: self.$conductor.baseFrequency,
                            range: 0...800)
            ParameterSlider(text: "Carrier Multiplier",
                            parameter: self.$conductor.carrierMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulating Multiplier",
                            parameter: self.$conductor.modulatingMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulation Index",
                            parameter: self.$conductor.modulationIndex,
                            range: 0...100)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.amplitude,
                            range: 0...2)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.rampDuration,
                            range: 0...10)
        }.navigationBarTitle(Text("FM Oscillator"))
        .padding()
        .onAppear {
            self.conductor.start()
        }
    }
}

struct FMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        FMOscillatorView()
    }
}
