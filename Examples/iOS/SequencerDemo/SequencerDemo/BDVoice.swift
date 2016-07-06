//
//  BDVoice.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class BDVoice: AKVoice {
    var generator: AKOperationGenerator
    var filt: AKMoogLadder?
    
    override init() {
        
        let frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 40, duration: 0.03)
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: 0.3)
        let sine = AKOperation.sineWave(frequency: frequency, amplitude: volSlide)
        
        generator = AKOperationGenerator(operation: sine)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 666
        filt!.resonance = 0.00
        
        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = BDVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}
