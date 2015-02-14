//
//  SeqInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "SeqInstrument.h"

@implementation SeqInstrument

- (instancetype)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT CONTROL ==================================================
        _modulation  = [[AKInstrumentProperty alloc] initWithValue:1.0
                                                           minimum:0.5
                                                           maximum:2.0];
        [self addProperty:_modulation];
        
        // INSTRUMENT DEFINITION ===============================================        
        AKFMOscillator *fmOscillator = [AKFMOscillator oscillator];
        fmOscillator.baseFrequency = note.frequency;
        fmOscillator.carrierMultiplier.value = 2;
        fmOscillator.modulatingMultiplier = _modulation;
        fmOscillator.modulationIndex.value = 15;
        fmOscillator.amplitude.value = 0.2;
        [self connect:fmOscillator];
        
        // AUDIO OUTPUT ========================================================
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
    }
    return self;
}

@end

// -----------------------------------------------------------------------------
#  pragma mark - Sequence Instrument Note
// -----------------------------------------------------------------------------


@implementation SeqInstrumentNote

- (instancetype)init {
    self = [super init];
    if (self) {
        _frequency = [[AKNoteProperty alloc] initWithValue:220
                                                   minimum:110
                                                   maximum:880];
        [self addProperty:_frequency];
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency {
    self = [self init];
    if (self) {
        _frequency.value = frequency;
    }
    return self;
}



@end