//
//  AKOscillatorBankMonophonic.swift
//  BlackboxAudioTestbed
//
//  Created by Ryan McLeod on 4/19/17.
//  Copyright © 2017 Ryan McLeod. All rights reserved.
//

import AudioKit

class AKOscillatorBankMonophonic : AKOscillatorBank
{
    var playingNote = false
    var currentNote: MIDINoteNumber = 0
    var noteStoppers: [MIDINoteNumber:Timer] = [:]
        
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
