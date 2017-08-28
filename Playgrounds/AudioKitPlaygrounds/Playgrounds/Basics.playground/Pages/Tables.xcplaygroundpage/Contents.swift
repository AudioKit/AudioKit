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
let sawtooth = AKTable(.sawtooth, count: 128)
let sine = AKTable(.sine, count: 256)

let file = try AKAudioFile(readFileName: "drumloop.wav")
let fileTable = AKTable(file: file)

var custom = AKTable(.sine, count: 256)
for i in custom.indices {
    custom[i] += Float(random(-0.3, 0.3) + Double(i) / 2_048.0)
}

import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {

        addTitle("Tables")

        addLabel("Square")
        addSubview(AKTableView(square))

        addLabel("Triangle")
        addSubview(AKTableView(triangle))

        addLabel("Sawtooth")
        addSubview(AKTableView(sawtooth))

        addLabel("Sine")
        addSubview(AKTableView(sine))

        addLabel("File")
        addSubview(AKTableView(fileTable))

        addLabel("Custom")
        addSubview(AKTableView(custom))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
