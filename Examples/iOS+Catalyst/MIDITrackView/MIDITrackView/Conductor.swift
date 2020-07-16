//
//  Conductor.swift
//  MIDIView
//
//  Created by Evan Murray on 7/15/20.
//

import Foundation
import AudioKit

class Conductor {
    var sampler: AKMIDISampler
    var sequencer: AKAppleSequencer!
    
    init(){
        sampler = AKMIDISampler(name: "Track")
        sequencer = AKAppleSequencer()
    }
    
    func loadSequencerWithFile(url: URL) {
        sequencer = AKAppleSequencer(fromURL: url)
    }
}
