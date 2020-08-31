//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: So, what about connecting multiple sources to the output instead of
//: feeding operations into each other in sequential order? To do that, you'll need a mixer.
import AudioKitPlaygrounds
import AudioKit

class Conductor: ObservableObject {

    var drums: AKPlayer
    var bass: AKPlayer
    var guitar: AKPlayer
    var lead: AKPlayer
    var mixer: AKMixer
    var booster: AKBooster

    init() {

        let drumFile = try! AKAudioFile(readFileName: "drumloop.wav")
        let bassFile = try! AKAudioFile(readFileName: "bassloop.wav")
        let guitarFile = try! AKAudioFile(readFileName: "guitarloop.wav")
        let leadFile = try! AKAudioFile(readFileName: "leadloop.wav")

        drums = AKPlayer(audioFile: drumFile)
        bass = AKPlayer(audioFile: bassFile)
        guitar = AKPlayer(audioFile: guitarFile)
        lead = AKPlayer(audioFile: leadFile)

        mixer = AKMixer(drums, bass, guitar, lead)
        booster = AKBooster(mixer)

        drums.isLooping = true
        drums.buffering = .always
        bass.isLooping = true
        bass.buffering = .always
        guitar.isLooping = true
        guitar.buffering = .always
        lead.isLooping = true
        lead.buffering = .always

        drums.volume = 0.9
        bass.volume = 0.9
        guitar.volume = 0.6
        lead.volume = 0.7

        drums.pan = 0.0
        bass.pan = 0.0
        guitar.pan = 0.2
        lead.pan   = -0.2
    }

    func start() {
        engine.output = booster
        try! engine.start()
    }

    func play() {
        drums.play()
        bass.play()
        guitar.play()
        lead.play()
    }

    func stop() {
        drums.stop()
        bass.stop()
        guitar.stop()
        lead.stop()
    }
}

import Cocoa
import PlaygroundSupport
import SwiftUI

let conductor = Conductor()
let view = NSHostingView(rootView: ContentView().environmentObject(conductor))
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

// Make a SwiftUI view
struct ContentView: View {
    @EnvironmentObject var conductor: Conductor
    var body: some View {
        VStack {
            Text("Mixing Nodes").font(.title)
            Divider()

            HStack {
                Button(action: { self.conductor.play() }) {
                    Text("Play")
                }
                Button(action: { self.conductor.stop() }) {
                    Text("Stop")
                }
            }
            Divider()

            Text("Volume").font(.headline)
            VStack {
                Slider(value: $conductor.drums.volume,  label: { Text("Drums") .frame(width: 100) } )
                Slider(value: $conductor.bass.volume,   label: { Text("Bass")  .frame(width: 100) } )
                Slider(value: $conductor.guitar.volume, label: { Text("Guitar").frame(width: 100) } )
                Slider(value: $conductor.lead.volume,   label: { Text("Lead")  .frame(width: 100) } )
                Slider(value: $conductor.booster.gain,  label: { Text("All")   .frame(width: 100) } )
            }
            Divider()
            Text("Pan").font(.headline)
            VStack {
                Slider(value: $conductor.drums.pan, in: -1...1, label: { Text("Drums").frame(width: 100) } )
                Slider(value: $conductor.bass.pan,  in: -1...1, label: { Text("Bass") .frame(width: 100) } )
                Slider(value: $conductor.guitar.pan, in: -1...1, label: { Text("Guitar").frame(width: 100) } )
                Slider(value: $conductor.lead.pan, in: -1...1, label: { Text("Lead").frame(width: 100) } )
            }

            }.frame(width: 300).onAppear(perform: { self.conductor.start() })
    }
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
