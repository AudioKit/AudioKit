//
//  MIDI Connection Manager.swift
//
//  Created by Kurt Arnlund on 1/14/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  Interactive MIDI I/O connection manager for command line testing

import Foundation
import AudioKit

class MIDIConnectionManger {

    let midi = AudioKit.midi
    var input: MIDIUniqueID = 0
    var inputIndex: Int = 0
    var output: MIDIUniqueID = 0
    var outputIndex: Int = 0
    public let tempoListener = AKMIDITempoListener(smoothing: 0.98, bpmHistoryLimit: 1)

    init() {
        midi.addListener(tempoListener)
        tempoListener.clockListener?.addObserver(self)
        tempoListener.addObserver(self)
        //midi.addListener(self)
    }

    deinit {
        midi.closeInput(uid: input)
        midi.closeOutput(uid: output)

        midi.removeListener(self)
    }

    var hasIOConnections: Bool {
        return input != 0 || output != 0
    }

    func openAll() {
        midi.createVirtualPorts()
        midi.openInput(); // open all inputs
        midi.openOutput() // open all outputs?
    }

    func closeAll() {
        midi.closeAllInputs()
        midi.closeOutput()
    }

    func selectIO() {
        var confirmed = false
        while confirmed == false {
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
        midi.openInput(uid: input)
        midi.openOutput(uid: output)
    }

    func selectInput() {
        var userInputAccepted = false
        while userInputAccepted == false {
            var num = 1
            for input in midi.inputInfos {
                print("\(num) : \(input.manufacturer) \(input.displayName)")
                num += 1
            }
            print("Select input: ")
            let inputLn = readLine()
            let inputNum = Int(inputLn ?? "") ?? 0
            if inputNum > 0 && inputNum <= midi.inputNames.count {
                let index = inputNum - 1
                input = midi.inputUIDs[index]
                inputIndex = index
                userInputAccepted = true
            } else {
                print("No input selected.")
            }
        }
    }

    private func selectOutput() {
        var userInputAccepted = false
        while userInputAccepted == false {
            var num = 1
            for dest in midi.destinationInfos {
                print("\(num) : \(dest.manufacturer) \(dest.displayName)")
                num += 1
            }
            print("Select output: ")
            let outputLn = readLine()
            let outputNum = Int(outputLn ?? "") ?? 0
            if outputNum > 0 && outputNum <= midi.destinationNames.count {
                let index = outputNum - 1
                output = midi.destinationUIDs[index]
                outputIndex = index
                userInputAccepted = true
            } else {
                print("No output selected.")
            }
        }
    }

    private func displayIOSelections() {
        let dest = midi.destinationInfos[outputIndex]
        let src = midi.inputInfos[inputIndex]

        print(" Input: \(src.manufacturer) \(src.displayName)")
        print("Output: \(dest.manufacturer) \(dest.displayName)")
    }
}

extension MIDIConnectionManger: AKMIDIListener {

    func receivedMIDISetupChange() {
        print("MIDI Setup Changed")
        selectIO()
    }
}

extension MIDIConnectionManger: AKMIDITempoObserver {

    func receivedTempo(_ bpm: BPMType, bpmStr: String) {
        print("[BPM] ", bpmStr)
    }

    func midiClockSlaveMode() {

    }

    func midiClockMasterEnabled() {

    }
}

extension MIDIConnectionManger: AKMIDIBeatObserver {

    func preparePlay(continue: Bool) {
        debugPrint("MMC Start Prepare Play")
    }

    func startFirstBeat(continue: Bool) {
        debugPrint("MMC Start First Beat")
    }

    func stopSRT() {
        debugPrint("MMC Stop")
    }

    func receivedBeatEvent(beat: UInt64) {

    }

    func receivedQuantum(quarterNote: UInt8, beat: UInt64, quantum: UInt64) {

    }

    func receivedQuarterNoteBeat(quarterNote: UInt8) {
        //debugPrint("Quarter Note: ", quarterNote)
    }
}
