//
//  SDVoice.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou on 6/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class SDVoice: AKVoice {
    var generator: AKOperationGenerator
    var filt: AKMoogLadder?
    var len = 0.143
    
    init(dur: Double = 0.143, res: Double = 0.9) {
        len = dur
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: len)
        
        let white = AKOperation.whiteNoise(amplitude: volSlide)
        generator = AKOperationGenerator(operation: white)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 1666
        resonance = res
        
        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }
    
    internal var cutoff: Double = 1666 {
        didSet {
            filt?.cutoffFrequency = cutoff
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
            filt?.resonance = resonance
        }
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SDVoice(dur: len, res:resonance)
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
