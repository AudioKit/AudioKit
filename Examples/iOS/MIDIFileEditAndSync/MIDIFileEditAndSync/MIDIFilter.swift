//
//  MIDIFilter.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import Foundation
import AudioKit

class MIDIFilter: FilterTableDelegate {

    var offsets = [Int]()

    init () {
        offsets = Array(repeating: 0, count: 12)
    }

    // get the pitch class and modify note by offset value
    var filterFunction: (AKMIDINoteData) -> AKMIDINoteData {
        return { note in
            var newNote = note
            let pitchClass = Int(note.noteNumber % 12)
            var noteNum = Int(note.noteNumber)
            noteNum += self.offsets[pitchClass]
            if 0 ..< 128 ~= noteNum {
                newNote.noteNumber = MIDINoteNumber(noteNum)
            }

            return newNote
        }
    }

    func changeOffset(pitchClass: Int, offset: Int) {
        guard 0..<12 ~= pitchClass else { return }
        offsets[pitchClass] = offset
    }
}

protocol FilterTableDelegate: class {
    var offsets: [Int] { get }
    func changeOffset(pitchClass: Int, offset: Int)
}
