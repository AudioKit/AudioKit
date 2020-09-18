//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//: ## Tables
//:
//: Tables are simply arrays of floats that can hold anything, but
//: usually waveforms.

import AudioKit

let square = Table(.square, count: 128)
let triangle = Table(.triangle, count: 128)
let sine = Table(.sine, count: 256)

let file = try AVAudioFile(readFileName: "drumloop.wav")
let fileTable = Table(file: file)

var custom = Table(.sine, count: 256)
for i in custom.indices {
    custom[i] += Float(random(in: -0.3...0.3) + Double(i) / 2_048.0)
}


class LiveView: View {

    override func viewDidLoad() {

        addTitle("Tables")

        addLabel("Square")
        addView(TableView(square))

        addLabel("Triangle")
        addView(TableView(triangle))

        addLabel("Sine")
        addView(TableView(sine))

        addLabel("File")
        addView(TableView(fileTable))

        addLabel("Custom")
        addView(TableView(custom))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
