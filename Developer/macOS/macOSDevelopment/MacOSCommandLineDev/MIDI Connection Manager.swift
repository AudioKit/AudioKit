//
//  MIDI Connection Manager.swift
//
//  Created by Kurt Arnlund on 1/14/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  Interactive MIDI I/O connection manager for command line testing

import Foundation
import AudioKit

class MidiConnectionManger : AKMIDIListener {
    let midi = AudioKit.midi

    var input : MIDIUniqueID = 0
    var input_index : Int = 0
    var output : MIDIUniqueID = 0
    var output_index : Int = 0

    init() {
        midi.addListener(self)
    }

    deinit {
        midi.closeInput(input)
        midi.closeOutput(output)

        midi.removeListener(self)
    }

    func receivedMIDISetupChange() {
        print("MIDI Setup Changed")
        selectIO()
    }

    var hasIOConnections: Bool {
        return input != 0 || output != 0
    }

    func selectIO() {
        var confirmed = false
        while (!confirmed) {
            selectInput()
            print("")
            selectOutput()
            print("")
            displayIOSelections()
            print("Is this ok [Y/n]: ")
            let userOk = readLine()
            if userOk?.uppercased() == "Y" {
                confirmed = true
            }
        }
        midi.openInput(input)
        midi.openOutput(output)
    }

    func selectInput() {
        var userInputAccepted = false
        while (!userInputAccepted) {
            var num = 1
            for input in midi.inputInfos {
                print("\(num) : \(input.manufacturer) \(input.displayName)")
                num = num + 1
            }
            print("Select input: ")
            let inputLn = readLine()
            let inputNum = Int(inputLn ?? "") ?? 0
            if inputNum > 0 && inputNum <= midi.inputNames.count {
                let index = inputNum - 1
                input = midi.inputUIDs[index]
                input_index = index
                userInputAccepted = true
            } else {
                print("No input selected.")
            }
        }
    }

    private func selectOutput() {
        var userInputAccepted = false
        while (!userInputAccepted) {
            var num = 1
            for dest in midi.destinationInfos {
                print("\(num) : \(dest.manufacturer) \(dest.displayName)")
                num = num + 1
            }
            print("Select output: ")
            let outputLn = readLine()
            let outputNum = Int(outputLn ?? "") ?? 0
            if outputNum > 0 && outputNum <= midi.destinationNames.count {
                let index = outputNum - 1
                output = midi.destinationUIDs[index]
                output_index = index
                userInputAccepted = true
            } else {
                print("No output selected.")
            }
        }
    }

    private func displayIOSelections() {
        let dest = midi.destinationInfos[output_index]
        let src = midi.inputInfos[input_index]

        print(" Input: \(src.manufacturer) \(src.displayName)")
        print("Output: \(dest.manufacturer) \(dest.displayName)")
    }
}
