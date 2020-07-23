import SwiftUI

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

struct MasterView: View {

    var body: some View {
        List {
            Section(header: Text("Proof Of Concept")) {
                NavigationLink(destination: DetailView()) { Text("Detail") }
                NavigationLink(destination: OscillatorView()) { Text("Oscillator") }
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
