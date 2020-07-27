import SwiftUI
import AVFoundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    @State private var dates = [Date]()

    var body: some View {
        NavigationView {
            MasterView()
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ParameterSlider: View {
    var text: String
    var parameter: Binding<AUValue>
    var range: ClosedRange<AUValue>

    var body: some View {
        GeometryReader { gp in
            HStack  {
                Spacer()
                Text(self.text).frame(width: gp.size.width * 0.2)
                Slider(value: self.parameter, in: self.range).frame(width: gp.size.width / 2)
                Text("\(self.parameter.wrappedValue)").frame(width: gp.size.width * 0.2)
                Spacer()
            }
        }
    }
}

struct MasterView: View {

    var body: some View {
        List {
            Section(header: Text("Proof Of Concept")) {
                NavigationLink(destination: DetailView()) { Text("Detail") }
                NavigationLink(destination: OscillatorView()) { Text("Oscillator") }
                NavigationLink(destination: FMOscillatorView()) { Text("FM Oscillator") }
                NavigationLink(destination: PluckedStringOperationView()) { Text("Plucekd String Operation") }
            }
        }.navigationBarTitle(Text("AudioKit"))
    }
}

struct DetailView: View {
    var body: some View {
        ZStack { Text("Detail View") }.navigationBarTitle(Text("Examples"))
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
