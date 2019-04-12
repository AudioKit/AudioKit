//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//: ## Tables
//:
//: Tables are simply arrays of floats that can hold anything, but
//: usually waveforms.
import AudioKitPlaygrounds
import AudioKit

let square = AKTable(.square, count: 128)
let triangle = AKTable(.triangle, count: 128)
let sine = AKTable(.sine, count: 256)

let file = try AKAudioFile(readFileName: "drumloop.wav")
let fileTable = AKTable(file: file)

var custom = AKTable(.sine, count: 256)
for i in custom.indices {
    custom[i] += Float(random(in: -0.3...0.3) + Double(i) / 2_048.0)
}

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {

        addTitle("Tables")

        addLabel("Square")
        addView(AKTableView(square))

        addLabel("Triangle")
        addView(AKTableView(triangle))

        addLabel("Sine")
        addView(AKTableView(sine))

        addLabel("File")
        addView(AKTableView(fileTable))

        addLabel("Custom")
        addView(AKTableView(custom))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
