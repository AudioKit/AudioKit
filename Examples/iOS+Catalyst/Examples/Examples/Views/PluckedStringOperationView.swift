import SwiftUI

struct PluckedStringOperationView: View {
    @ObservedObject var conductor = PluckedStringOperationConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
            }
//            Slider(value: self.$conductor.frequency, in: 220...880)

        }.navigationBarTitle(Text("Plucked String Operation"))
        .onAppear {
            self.conductor.start()
        }
    }
}

struct PluckedStringOperationView_Previews: PreviewProvider {
    static var previews: some View {
        PluckedStringOperationView()
    }
}
