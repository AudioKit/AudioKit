import SwiftUI

struct OscillatorView: View {
    @ObservedObject var conductor  = OscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
            }
            Slider(value: self.$conductor.frequency, in: 220...880)

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
