//
//  AKFMOscillatorBankMonophonic.swift
//  Blackbox
//
//  Created by Ryan McLeod on 4/28/17.
//  Copyright © 2017 Ryan McLeod. All rights reserved.
//

import AudioKit

// NOTE: This does the exact same thing as AKOscillatorBankMonophonic
//       Should this monophonic behavior instead be a category or protocol?
class AKFMOscillatorBankMonophonic : AKFMOscillatorBank
{
    var playingNote = false
    var currentNote: MIDINoteNumber = 0
    
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity)
    {
        if (!playingNote || (currentNote != noteNumber))
        {
            super.stop(noteNumber: currentNote)
            super.play(noteNumber: noteNumber, velocity: velocity)
        }
        currentNote = noteNumber
    }
    
    override func stop(noteNumber: MIDINoteNumber)
    {
        super.stop(noteNumber: currentNote)
        playingNote = false
    }
    
    public func stopCurrentNote()
    {
        self.stop(noteNumber: currentNote)
    }
}
