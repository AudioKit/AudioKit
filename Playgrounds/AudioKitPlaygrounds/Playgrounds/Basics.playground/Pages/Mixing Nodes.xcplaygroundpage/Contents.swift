//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: So, what about connecting multiple sources to the output instead of
//: feeding operations into each other in sequential order? To do that, you'll need a mixer.

import AudioKit

class Conductor: ObservableObject {

    var drums: AudioPlayer
    var bass: AudioPlayer
    var guitar: AudioPlayer
    var lead: AudioPlayer
    var mixer: Mixer
    var fader: Fader

    init() {

        let drumFile = try! AVAudioFile(readFileName: "drumloop.wav")
        let bassFile = try! AVAudioFile(readFileName: "bassloop.wav")
        let guitarFile = try! AVAudioFile(readFileName: "guitarloop.wav")
        let leadFile = try! AVAudioFile(readFileName: "leadloop.wav")

        drums = AudioPlayer(audioFile: drumFile)
        bass = AudioPlayer(audioFile: bassFile)
        guitar = AudioPlayer(audioFile: guitarFile)
        lead = AudioPlayer(audioFile: leadFile)

        mixer = Mixer(drums, bass, guitar, lead)
        fader = Fader(mixer)

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
        engine.output = fader
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
                Slider(value: $conductor.fader.gain,  label: { Text("All")   .frame(width: 100) } )
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
